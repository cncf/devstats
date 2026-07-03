#!/usr/bin/env python3
"""
verify_gha_archive_against_db.py  (PHASE 1 - raw data research)

Independently verify that DevStats did NOT miss any GH Archive event for a project (default: Kubernetes)
over a date range, and detect whether GH Archive itself is thinner upstream.

For every requested UTC hour it:
  1. Downloads the raw GH Archive hourly file (https://data.gharchive.org/YYYY-MM-DD-H.json.gz).
  2. Applies the SAME org/repo filter that `gha2db` applies on ingestion (devstatscode/gha.go RepoHit):
     an event "hits" iff its repo full name `org/repo` has `org` in the project org set AND the full name
     is NOT in the exclude-repos set.
  3. Buckets matching event IDs by the event's own `created_at` hour.
  4. Queries `gha_events` for the real (non-artificial) event IDs in the same created_at hour and compares.

WHAT IT PROVES / DOES NOT PROVE:
  * It is decisive for "did DevStats miss GH Archive event IDs?".
  * It does NOT prove the payloads are still complete. If missing_in_db==0, remaining dashboard drops are
    UPSTREAM volume reduction and/or UPSTREAM payload weakening (e.g. PushEvent losing commit lists from
    2025-10-07), plus any downstream API/git enrichment gaps. Use --payload-stats to see event-type volume
    and payload-presence, and the SQL audit's enrichment coverage section for the rest.

CRITICAL: a failed/absent download or a corrupt/undecodable file is NEVER treated as "empty archive". Each
hour is classified ok / not_found(404) / failed(network) / corrupt(gzip or JSON decode). If any hour could
not be trusted the run exits NON-ZERO, so you can never conclude "decline is upstream" off a download error.
Use --allow-missing-archive-files only for near-current hours GH Archive has not published yet.
JSON policy: ANY JSON decode error fails that hour as corrupt (decisive by design; malformed lines are never
silently ignored). If a real historical window proves noisy, add a future opt-in threshold (e.g. --allow-json-errors N).

DB access uses the `psql` CLI (standard PG* env vars). No third-party Python packages are required.
Run this on a WORKSTATION - it is intentionally NOT shipped in the DevStats images (images stay shell + Go).

The Kubernetes --orgs / --exclude-repos defaults below mirror devstats/projects.yaml at the time of writing.
For non-Kubernetes projects, or after any projects.yaml filter change, pass --orgs / --exclude-repos
explicitly from the current projects.yaml so this stays in sync.

Examples:
  PGHOST=$PG_HOST PGPORT=$PG_PORT PGUSER=gha_admin PGPASSWORD=$PG_PASS \\
    ./util_py/verify_gha_archive_against_db.py --db gha \\
      --from '2025-10-08T00:00:00' --to '2025-10-10T00:00:00' --workers 6 --diff-dir /tmp/gha-audit
  ... --payload-stats                       # also print event-type + payload-presence counts
  ... --allow-missing-archive-files         # for near-current, not-yet-published hours

Each hourly file is ~100-150 MB compressed; sample long ranges with --sample-every N or scan narrow windows.
"""
from __future__ import annotations

import argparse
import collections
import datetime as dt
import gzip
import io
import json
import os
import subprocess
import sys
import shlex
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed

# Artificial (ghapi2db) event IDs are ARTIFICIAL_BASE + real_event_id, and real_event_id >= 1, so:
#   real GH Archive IDs : id <  ARTIFICIAL_BASE            (== 2**48)
#   ghapi2db artificial : id >= ARTIFICIAL_BASE + 1
#   sync events         : id >= 329900000000000
# (The postprocess SQL uses `event_id < ARTIFICIAL_BASE + 1`, which is equivalent because id == 2**48 is unused.)
ARTIFICIAL_BASE = 281474976710656  # 2**48

# Download outcome per hourly file.
OK, NOT_FOUND, FAILED, CORRUPT = "ok", "not_found", "failed", "corrupt"

# Kubernetes project defaults (must match devstats/projects.yaml `kubernetes`).
DEFAULT_ORGS = (
    "kubernetes,kubernetes-client,kubernetes-incubator,kubernetes-csi,"
    "kubernetes-graveyard,kubernetes-incubator-retired,kubernetes-sig-testing,"
    "kubernetes-providers,kubernetes-addons,kubernetes-retired,"
    "kubernetes-extensions,kubernetes-federation,kubernetes-security,"
    "kubernetes-sidecars,kubernetes-tools,kubernetes-test,kubernetes-sigs"
)
DEFAULT_EXCLUDE_REPOS = (
    "kubernetes/api,kubernetes/apiextensions-apiserver,kubernetes/apimachinery,"
    "kubernetes/apiserver,kubernetes/client-go,kubernetes/code-generator,"
    "kubernetes/kube-aggregator,kubernetes/metrics,kubernetes/sample-apiserver,"
    "kubernetes/sample-controller,kubernetes/helm,kubernetes/deployment-manager,"
    "kubernetes/charts,kubernetes/cli-runtime,kubernetes/csi-api,"
    "kubernetes/kube-proxy,kubernetes/kube-controller-manager,"
    "kubernetes/kube-scheduler,kubernetes/kubelet,kubernetes/sample-cli-plugin,"
    "kubernetes/application-dm-templates,kubernetes/cluster-bootstrap,"
    "kubernetes/cloud-provider,kubernetes-sigs/cri-o,kubernetes-incubator/ocid,"
    "kubernetes-incubator/cri-o,kubernetes-sigs/headlamp"
)


def log(msg: str) -> None:
    print(msg, file=sys.stderr, flush=True)


def parse_dt(s: str) -> dt.datetime:
    s = s.strip().replace("Z", "")
    for fmt in ("%Y-%m-%dT%H:%M:%S", "%Y-%m-%dT%H:%M", "%Y-%m-%dT%H", "%Y-%m-%d %H:%M:%S", "%Y-%m-%d"):
        try:
            return dt.datetime.strptime(s, fmt)
        except ValueError:
            continue
    raise SystemExit(f"cannot parse datetime: {s!r}")


def hour_floor(t: dt.datetime) -> dt.datetime:
    return t.replace(minute=0, second=0, microsecond=0)


def gha_url(h: dt.datetime) -> str:
    # GH Archive uses non-zero-padded hour: YYYY-MM-DD-H
    return f"https://data.gharchive.org/{h.year:04d}-{h.month:02d}-{h.day:02d}-{h.hour}.json.gz"


def hour_range(frm: dt.datetime, to: dt.datetime):
    cur, end = hour_floor(frm), hour_floor(to)
    while cur < end:
        yield cur
        cur += dt.timedelta(hours=1)


def download(url: str, retries: int, timeout: int) -> tuple[str, bytes | None]:
    """Return (status, body). status distinguishes 404 (absent) from network failure."""
    last = None
    for attempt in range(1, retries + 1):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "devstats-gha-verifier"})
            with urllib.request.urlopen(req, timeout=timeout * attempt) as resp:
                return OK, resp.read()
        except urllib.error.HTTPError as e:
            last = e
            if e.code == 404:
                return NOT_FOUND, None  # hour not published (yet)
        except Exception as e:  # noqa: BLE001 - network robustness
            last = e
        if attempt < retries:
            time.sleep(min(30, 2 * attempt))
    log(f"  download failed: {url}: {last}")
    return FAILED, None


def event_created_hour(created_at: str) -> dt.datetime | None:
    try:
        t = dt.datetime.strptime(created_at.replace("Z", ""), "%Y-%m-%dT%H:%M:%S")
    except (ValueError, AttributeError):
        return None
    return t.replace(minute=0, second=0, microsecond=0)


def scan_archive(raw: bytes, orgs: set[str], exclude: set[str], collect_stats: bool = False):
    """Return (events_by_hour, payload_stats_by_hour). Raises ValueError on ANY JSON decode error and
    propagates gzip errors, so a corrupt/undecodable file is treated as CORRUPT (never silently thinned)."""
    out: dict[dt.datetime, set[int]] = {}
    stats_by_hour: dict[dt.datetime, collections.Counter] = {}
    json_errors = 0
    with gzip.GzipFile(fileobj=io.BytesIO(raw)) as gz:
        for line in gz:  # gzip stream corruption raises here -> CORRUPT
            if not line.strip():
                continue
            try:
                ev = json.loads(line)
            except ValueError:
                json_errors += 1
                continue
            repo = ev.get("repo") or {}
            full = repo.get("name") or ""
            if not full or "/" not in full or full in exclude:
                continue
            if full.split("/", 1)[0] not in orgs:
                continue
            eid_raw = ev.get("id")
            h = event_created_hour(ev.get("created_at", ""))
            if eid_raw is None or h is None:
                continue
            try:
                out.setdefault(h, set()).add(int(eid_raw))
            except (TypeError, ValueError):
                continue
            if collect_stats:
                sc = stats_by_hour.setdefault(h, collections.Counter())
                typ = ev.get("type") or "?"
                sc[typ] += 1
                pl = ev.get("payload") or {}
                if typ == "PushEvent" and pl.get("commits"):
                    sc["PushEvent:with_commits"] += 1
                elif typ == "PullRequestEvent" and pl.get("pull_request"):
                    sc["PullRequestEvent:with_pull_request"] += 1
    if json_errors:
        raise ValueError(f"{json_errors} JSON decode error(s) in archive line(s)")
    return out, stats_by_hour

def psql_cmd(db: str, sql: str, psql_prefix: str) -> list[str]:
    """
    Build the psql command.

    Default:
      psql -v ON_ERROR_STOP=1 -tAq <db> -c <sql>

    With --psql-prefix, for example:
      kubectl --context prod exec -i -n devstats-prod devstats-postgres-0 -c devstats-postgres -- \
        psql -v ON_ERROR_STOP=1 -tAq <db> -c <sql>
    """
    return shlex.split(psql_prefix) + ["psql", "-v", "ON_ERROR_STOP=1", "-tAq", db, "-c", sql]


def run_psql(db: str, sql: str, psql_prefix: str) -> str:
    res = subprocess.run(psql_cmd(db, sql, psql_prefix), capture_output=True, text=True)
    if res.returncode != 0:
        raise SystemExit(f"psql failed: {res.stderr.strip()}")
    return res.stdout


def db_ids_for_hour(db: str, h: dt.datetime, psql_prefix: str) -> set[int]:
    nxt = h + dt.timedelta(hours=1)
    sql = (
        "select id from gha_events "
        f"where created_at >= '{h:%Y-%m-%d %H:%M:%S}' and created_at < '{nxt:%Y-%m-%d %H:%M:%S}' "
        f"and id < {ARTIFICIAL_BASE}"
    )
    try:
        return {int(tok) for tok in run_psql(db, sql, psql_prefix).split() if tok.strip()}
    except SystemExit as e:
        raise SystemExit(f"psql failed for hour {h}: {e}") from e


def main() -> int:
    ap = argparse.ArgumentParser(description="Verify GH Archive events against DevStats gha_events.")
    ap.add_argument("--db", default=os.getenv("PG_DB", "gha"), help="project Postgres DB (default gha / $PG_DB)")
    ap.add_argument("--from", dest="frm", required=True, help="range start (UTC), e.g. 2025-10-08T00:00:00")
    ap.add_argument("--to", dest="to", required=True, help="range end (UTC, exclusive)")
    ap.add_argument("--orgs", default=DEFAULT_ORGS, help="comma-separated org allow-list (from projects.yaml)")
    ap.add_argument("--exclude-repos", default=DEFAULT_EXCLUDE_REPOS, help="comma-separated org/repo exclude-list")
    ap.add_argument("--workers", type=int, default=4, help="parallel hour downloads")
    ap.add_argument("--retries", type=int, default=5)
    ap.add_argument("--timeout", type=int, default=120, help="base per-attempt HTTP timeout (s)")
    ap.add_argument("--sample-every", type=int, default=1, help="only check every Nth hour (quick coverage scan)")
    ap.add_argument("--diff-dir", default="", help="if set, write per-hour missing/extra id lists here")
    ap.add_argument("--csv", default="", help="write per-hour results to this CSV file (else stdout)")
    ap.add_argument("--payload-stats", action="store_true",
                    help="also print matching event-type counts and payload-presence (PushEvent->commits, PullRequestEvent->pull_request)")
    ap.add_argument("--allow-missing-archive-files", action="store_true",
                    help="treat 404 (unpublished) hours as OK instead of failing - use only for near-current hours")
    ap.add_argument("--psql-prefix", default=os.getenv("GHA_VERIFY_PSQL_PREFIX", ""),
                    help="optional command prefix before psql, for example: "
                         "'kubectl --context prod exec -i -n devstats-prod devstats-postgres-0 "
                         "-c devstats-postgres --'")
    args = ap.parse_args()

    frm, to = parse_dt(args.frm), parse_dt(args.to)
    if frm >= to:
        raise SystemExit(f"--from must be before --to, got {frm} >= {to}")
    orgs = {o.strip() for o in args.orgs.split(",") if o.strip()}
    exclude = {r.strip() for r in args.exclude_repos.split(",") if r.strip()}
    if args.diff_dir:
        os.makedirs(args.diff_dir, exist_ok=True)

    # Fail fast before downloading tens of GB from GH Archive.
    try:
        got = run_psql(args.db, "select 1", args.psql_prefix).strip()
    except SystemExit as e:
        raise SystemExit(f"database preflight failed: {e}") from e
    if got != "1":
        raise SystemExit(f"database preflight failed: expected 1, got {got!r}")

    hours = [h for i, h in enumerate(hour_range(frm, to)) if i % max(1, args.sample_every) == 0]
    # Pad one hour each side so events near an hour boundary (written to an adjacent GH Archive file) are captured.
    fetch_hours = sorted(set(hours) | {h - dt.timedelta(hours=1) for h in hours} | {h + dt.timedelta(hours=1) for h in hours})
    log(f"Checking {len(hours)} hour(s) (downloading {len(fetch_hours)} incl. padding) with {args.workers} workers")

    archive_by_hour: dict[dt.datetime, set[int]] = {}
    file_status: dict[dt.datetime, str] = {}
    payload_stats_by_hour: dict[dt.datetime, collections.Counter] = {}

    def fetch_and_scan(fh: dt.datetime):
        status, raw = download(gha_url(fh), args.retries, args.timeout)
        if status != OK:
            return fh, status, None, None
        try:
            out, sbh = scan_archive(raw, orgs, exclude, collect_stats=args.payload_stats)
            return fh, OK, out, sbh
        except (OSError, EOFError, gzip.BadGzipFile, ValueError) as e:  # corrupt gzip OR JSON decode error
            log(f"  corrupt/undecodable archive {gha_url(fh)}: {e}")
            return fh, CORRUPT, None, None

    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        futs = {ex.submit(fetch_and_scan, fh): fh for fh in fetch_hours}
        done = 0
        for fut in as_completed(futs):
            fh, status, scanned, sbh = fut.result()
            file_status[fh] = status
            done += 1
            if scanned:
                for h, ids in scanned.items():
                    archive_by_hour.setdefault(h, set()).update(ids)
            if sbh:
                for h, c in sbh.items():
                    payload_stats_by_hour.setdefault(h, collections.Counter()).update(c)
            if done % 25 == 0 or done == len(fetch_hours):
                log(f"  downloaded {done}/{len(fetch_hours)} files")

    # Aggregate download problems across the fetched files (including padding).
    n_not_found = sum(1 for s in file_status.values() if s == NOT_FOUND)
    n_failed = sum(1 for s in file_status.values() if s == FAILED)
    n_corrupt = sum(1 for s in file_status.values() if s == CORRUPT)

    out = open(args.csv, "w") if args.csv else sys.stdout
    print("hour,gharchive_events,db_events,missing_in_db,extra_in_db,status", file=out)
    tot_arch = tot_db = tot_missing = tot_extra = 0
    miss_hours = 0
    for h in hours:
        arch = archive_by_hour.get(h, set())
        dbids = db_ids_for_hour(args.db, h, args.psql_prefix)
        missing = arch - dbids   # in GH Archive but not in DevStats DB (the important one)
        extra = dbids - arch     # in DB but not in the current GH Archive file
        tot_arch += len(arch); tot_db += len(dbids); tot_missing += len(missing); tot_extra += len(extra)
        # The hour's data comes from files [h-1, h, h+1]; flag if any of them was not fully downloaded.
        fstat = {file_status.get(h + dt.timedelta(hours=o), OK) for o in (-1, 0, 1)}
        if fstat & {FAILED, CORRUPT}:
            status = "download_problem"
        elif NOT_FOUND in fstat and not args.allow_missing_archive_files:
            status = "archive_404"
        elif missing:
            status = "MISSING"; miss_hours += 1
        elif extra:
            status = "extra"
        else:
            status = "ok"
        print(f"{h:%Y-%m-%dT%H},{len(arch)},{len(dbids)},{len(missing)},{len(extra)},{status}", file=out)
        if args.diff_dir and (missing or extra):
            with open(os.path.join(args.diff_dir, f"{h:%Y-%m-%d-%H}.txt"), "w") as df:
                df.writelines(f"missing_in_db {i}\n" for i in sorted(missing))
                df.writelines(f"extra_in_db {i}\n" for i in sorted(extra))
    if args.csv:
        out.close()

    log("")
    log("=== TOTALS ===")
    log(f"hours checked      : {len(hours)}")
    log(f"gharchive events   : {tot_arch}")
    log(f"db events          : {tot_db}")
    log(f"missing_in_db      : {tot_missing}  (hours with any miss: {miss_hours})")
    log(f"extra_in_db        : {tot_extra}")
    log(f"files 404/failed/corrupt: {n_not_found}/{n_failed}/{n_corrupt}")
    if args.payload_stats:
        payload_stats: collections.Counter = collections.Counter()
        for h in hours:  # only the requested checked hours, excluding the +/-1h padding files
            payload_stats.update(payload_stats_by_hour.get(h, {}))
        log("--- payload stats (matching events in the checked hours) ---")
        for k in ("PushEvent", "PushEvent:with_commits", "PullRequestEvent", "PullRequestEvent:with_pull_request",
                  "PullRequestReviewEvent", "PullRequestReviewCommentEvent", "IssueCommentEvent", "IssuesEvent"):
            log(f"  {k:34s}: {payload_stats.get(k, 0)}")

    untrusted = n_failed > 0 or n_corrupt > 0 or (n_not_found > 0 and not args.allow_missing_archive_files)
    if untrusted:
        log("RESULT: INCONCLUSIVE - some archive files could not be downloaded/parsed. Re-run those hours "
            "(or pass --allow-missing-archive-files only for near-current, not-yet-published hours).")
        return 2
    if tot_missing > 0:
        log("RESULT: DevStats is MISSING GH Archive events -> re-ingest the flagged hours (Phase 1 -> raw repair).")
        return 1
    log("RESULT: no missed GH Archive event IDs -> DevStats imported everything GH Archive had. Any remaining "
        "decline is UPSTREAM volume/payload weakening (+ enrichment gaps), NOT a sync miss.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
