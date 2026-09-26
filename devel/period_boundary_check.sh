#!/bin/bash
# Checks what happened at the last period boundary (d=00:00, w=Monday, m/q/y=1st) in every project DB:
# gha_computed markers, TSDB points of the concluded period and the gha2db_sync logs of the first sync after it.
# gha_logs are kept 1 week (GHA2DB_MAXLOGAGE) - run it within 7 days after the boundary.
# Usage: devel/period_boundary_check.sh [-s prod|test] [-c d,w,m,q,y] [-b YYYY-MM-DD] [-p proj,...] [-o outfile] [-v]
#   -c default: d,w plus m/q/y when their boundary is within the last 7 days; -b forces the boundary date
#   -p limits the check to the given projects; -v lists every project (default: problems and per-class summary)
#   exit 1 when any WARN
set -o pipefail
STAGE=prod CLASSES='' BDATE='' PROJS='' OUT='' VERBOSE=0
PG_USER="${PG_USER:-gha_admin}"
PG_CONTAINER="${PG_CONTAINER:-devstats-postgres}"
usage() { sed -n '2,8p' "$0"; exit 1; }
while getopts 's:c:b:p:o:vh' o; do
  case "$o" in
    s) STAGE="$OPTARG";; c) CLASSES="$OPTARG";; b) BDATE="$OPTARG";; p) PROJS="$OPTARG";; o) OUT="$OPTARG";; v) VERBOSE=1;; *) usage;;
  esac
done
case "$STAGE" in prod|test) ;; *) usage;; esac
if [ -n "$BDATE" ] && ! [[ "$BDATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then usage; fi
if [ -z "$CLASSES" ]; then
  dom=$(date -u +%d); mon=$(date -u +%m)
  CLASSES='d,w'
  if [ "${dom#0}" -le 7 ]; then
    CLASSES="$CLASSES,m"
    case "$mon" in 01|04|07|10) CLASSES="$CLASSES,q";; esac
    [ "$mon" = "01" ] && CLASSES="$CLASSES,y"
  fi
fi
NS="devstats-$STAGE"
CTX=""
kubectl config get-contexts -o name 2>/dev/null | grep -qx "$STAGE" && CTX="--context $STAGE"
kc() { kubectl $CTX -n "$NS" "$@"; }
POD=$(kc get pods -l role=primary,type=postgres -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
[ -z "$POD" ] && { echo "no primary postgres pod in $NS" >&2; exit 2; }
TMPD=$(mktemp -d); trap 'rm -rf "$TMPD"' EXIT
kc get cronjobs -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null | while read -r name; do
  case "$name" in
    devstats-affiliations-*|devstats-backups|devstats-affiliations) continue;;
    devstats-*) proj="${name#devstats-}";;
    *) continue;;
  esac
  [ -n "$PROJS" ] && ! [[ ",$PROJS," == *",$proj,"* ]] && continue
  db="$proj"
  [ "$proj" = "kubernetes" ] && db="gha"
  [ "$proj" = "all" ] && db="allprj"
  echo "$db"
done | sort -u > "$TMPD/dbs.txt"
[ -s "$TMPD/dbs.txt" ] || { echo "no sync CronJobs found in $NS" >&2; exit 2; }

if [ -t 1 ]; then R=$'\e[31m'; Y=$'\e[33m'; G=$'\e[32m'; B_=$'\e[1m'; N=$'\e[0m'; else R=''; Y=''; G=''; B_=''; N=''; fi
[ -n "$OUT" ] && : > "$OUT"
ESC=$(printf '\033')
out() { echo "$@"; [ -n "$OUT" ] && echo "$@" | sed "s/${ESC}\[[0-9;]*m//g" >> "$OUT"; }
WARNS=0

# one class per pass: a bash script piped into the PG pod runs the per-DB query on every DB and the logs query on 'devstats'
for c in $(echo "$CLASSES" | tr ',' ' '); do
  case "$c" in
    d) unit=day; len='1 day';; w) unit=week; len='1 week';; m) unit=month; len='1 month';;
    q) unit=quarter; len='3 months';; y) unit=year; len='1 year';; *) echo "unknown class: $c" >&2; exit 1;;
  esac
  bsel="coalesce(nullif('$BDATE', '')::timestamp, date_trunc('$unit', now() at time zone 'UTC'))"
  dbq="with b as (select $bsel b, interval '$len' len),
m as (select metric, split_part(metric, ' ', 3) p, dt from gha_computed where metric like '% % %'),
mk as (select count(distinct metric) filter (where p ~ '^${c}[0-9]*\$') total,
  count(distinct metric) filter (where p ~ '^${c}[0-9]*\$' and dt >= (select b from b)) after,
  to_char(min(dt) filter (where p ~ '^${c}[0-9]*\$' and dt >= (select b from b)), 'YYYY-MM-DD HH24:MI') first_after,
  coalesce(bool_or(p ~ '^h[0-9]*\$' and dt >= (select b from b)), false) h_after,
  to_char(max(dt) filter (where p ~ '^h[0-9]*\$'), 'YYYY-MM-DD HH24:MI') last_h from m),
t as (select table_name tn from information_schema.columns where table_schema = 'public' and column_name = 'period' and table_name like 's%'),
x as (select tn,
  (xpath('/row/n/text()', query_to_xml(format('select count(*) n from %I where period = %L and time = %L', tn, '$c', b.b - 2 * b.len), false, true, '')))[1]::text::int n_prev,
  (xpath('/row/n/text()', query_to_xml(format('select count(*) n from %I where period = %L and time = %L', tn, '$c', b.b - b.len), false, true, '')))[1]::text::int n_concl,
  (xpath('/row/n/text()', query_to_xml(format('select count(*) n from %I where period = %L and time = %L', tn, '$c', b.b), false, true, '')))[1]::text::int n_new from t, b),
ts as (select count(*) filter (where n_prev > 0) t_prev, count(*) filter (where n_concl > 0) t_concl, count(*) filter (where n_new > 0) t_new,
  coalesce(string_agg(tn, ',' order by tn) filter (where n_prev > 0 and n_concl = 0), '-') gaps from x)
select to_char(b.b, 'YYYY-MM-DD'), mk.total, mk.after, coalesce(mk.first_after, '-'), mk.h_after::int, coalesce(mk.last_h, '-'), ts.t_prev, ts.t_concl, ts.t_new, ts.gaps from b, mk, ts"
  ymdh() { echo "(split_part($1, ' ', 1) || ' ' || split_part($1, ' ', 2) || ':00')::timestamp"; }
  logq="with b as (select $bsel b),
l as (select proj, run_dt, dt, msg from gha_logs where prog = 'gha2db_sync' and run_dt >= (select b from b) - interval '1 hour' and dt >= (select b from b) - interval '1 hour'
  and (msg like 'TS range: %' or msg like 'Calculate metric %' or msg like 'Scheduled histogram metric %' or msg like 'Period \"%was not computed successfully%'
    or msg like 'Skipping recalculating period \"%' or msg in ('Run tags', 'Run columns finished', 'Sync success') or msg like 'Time: %')),
r as (select proj, run_dt, max(dt) last_dt,
  max(substring(msg from '^TS range: (.*) - .*\$')) filter (where msg like 'TS range: %') f,
  max(substring(msg from '^TS range: .* - (.*)\$')) filter (where msg like 'TS range: %') t,
  count(*) filter (where (msg like 'Calculate metric %' or msg like 'Scheduled histogram metric %') and substring(msg from ', period ([a-z])') = '$c') n_calc,
  count(*) filter (where msg like 'Period \"$c%was not computed successfully%') n_rep,
  count(*) filter (where msg like 'Skipping recalculating period \"$c%') n_skip,
  count(*) filter (where msg = 'Run tags') n_tags, count(*) filter (where msg = 'Run columns finished') n_cols,
  bool_or(msg = 'Sync success') ok, max(substring(msg from '^Time: (.*)\$')) filter (where msg like 'Time: %') tm from l group by proj, run_dt),
r2 as (select *, case when f is null then null else $(ymdh f) end fts, case when t is null then null else $(ymdh t) end tts from r)
select proj, to_char(run_dt, 'YYYY-MM-DD HH24:MI:SS'), coalesce(f, '-'), coalesce(t, '-'),
  case when fts < (select b from b) and tts >= (select b from b) then 1 else 0 end crosses,
  case when fts < date_trunc('$unit', tts) then 1 else 0 end due,
  n_calc, n_rep, n_skip, n_tags, n_cols, ok::int, extract(epoch from now() at time zone 'UTC' - last_dt)::int age_s, coalesce(tm, '-'),
  case when fts < (select b from b) - 2 * interval '$len' then 1 else 0 end full_recompute
from r2 order by proj, run_dt"
  {
    echo 'while read -r db; do'
    echo "  v=\$(psql -U $PG_USER -d \"\$db\" -X -tA -F'|' -v ON_ERROR_STOP=1 -f - <<'SQLEOF' 2>/dev/null"
    echo "$dbq"
    echo 'SQLEOF'
    echo '  )'
    echo '  echo "M|$db|${v:-err}"'
    echo 'done <<EOF_LIST'
    cat "$TMPD/dbs.txt"
    echo 'EOF_LIST'
    echo "psql -U $PG_USER -d devstats -X -tA -F'|' -v ON_ERROR_STOP=1 -f - <<'SQLEOF' 2>&1 | sed 's/^/L|/'"
    echo "$logq"
    echo 'SQLEOF'
  } > "$TMPD/remote-$c.sh"
  kc exec -i -c "$PG_CONTAINER" "$POD" -- bash -s < "$TMPD/remote-$c.sh" > "$TMPD/rows-$c.txt" 2> "$TMPD/err-$c.txt"
  [ -s "$TMPD/rows-$c.txt" ] || { echo "no data for class $c:" >&2; cat "$TMPD/err-$c.txt" >&2; WARNS=$((WARNS+1)); continue; }
  out "${B_}== class $c (${unit} boundary) on $NS, $(wc -l < "$TMPD/dbs.txt" | tr -d ' ') DBs ==${N}"
  awk -F'|' -v c="$c" -v verbose="$VERBOSE" -v R="$R" -v Y="$Y" -v G="$G" -v N="$N" '
    function proj_of(db) { return db == "gha" ? "kubernetes" : (db == "allprj" ? "all" : db) }
    function secs(s,  v, n) {  # go duration -> seconds (54.5ms -> 0)
      if (s ~ /ms$/) return 0
      v = 0
      if (match(s, /[0-9]+h/)) v += substr(s, RSTART, RLENGTH - 1) * 3600
      n = s; sub(/.*h/, "", n)
      if (match(n, /[0-9]+m/)) v += substr(n, RSTART, RLENGTH - 1) * 60
      if (match(s, /[0-9.]+s$/)) v += substr(s, RSTART, RLENGTH - 1)
      return int(v)
    }
    function hdur(s) { if (s >= 3600) return int(s / 3600) "h" int((s % 3600) / 60) "m"; if (s >= 60) return int(s / 60) "m" (s % 60) "s"; return s "s" }
    function median(arr, n,  i, j, t, a) {
      if (n == 0) return 0
      for (i = 1; i <= n; i++) a[i] = arr[i]
      for (i = 2; i <= n; i++) { t = a[i]; for (j = i - 1; j >= 1 && a[j] > t; j--) a[j + 1] = a[j]; a[j + 1] = t }
      return a[int((n + 1) / 2)]
    }
    function emit(kind, p, txt) {
      if (kind == "WARN") { nwarn++; bad = 1; print R "WARN" N " [" c "] " p ": " txt }
      else if (kind == "NOTE") { nnote++; print Y "NOTE" N " [" c "] " p ": " txt }
      else { nok++; if (verbose) print G "OK  " N " [" c "] " p ": " txt }
    }
    $1 == "M" {
      p = proj_of($2); projs[++np] = p
      if ($3 == "err" || NF < 12) { merr[p] = 1; next }
      B = $3; total[p] = $4; after[p] = $5; first[p] = $6; hafter[p] = $7; lasth[p] = $8; tprev[p] = $9; tconcl[p] = $10; tnew[p] = $11; gaps[p] = $12
      next
    }
    $1 == "L" && NF >= 16 {
      p = $2; i = ++nrun[p]
      rd[p, i] = $3; rf[p, i] = $4; rt[p, i] = $5; rcross[p, i] = $6; rdue[p, i] = $7; rcalc[p, i] = $8; rrep[p, i] = $9; rskip[p, i] = $10
      rtags[p, i] = $11; rcols[p, i] = $12; rok[p, i] = $13; rage[p, i] = $14; rtm[p, i] = $15; rsecs[p, i] = secs($15); rfull[p, i] = $16
      next
    }
    $1 == "L" { lerr = lerr "\n" $0 }
    END {
      if (lerr != "") { nwarn++; print R "WARN" N " [" c "] logs query failed:" lerr }
      for (k = 1; k <= np; k++) {
        p = projs[k]; bad = 0
        if (p in merr) { emit("WARN", p, "cannot read gha_computed/TSDB (DB missing?)"); continue }
        # runs after the boundary: first crossing one = the boundary sync; the others are regular / full recomputes (affiliations, RESETTSDB)
        ci = 0; nreg = 0; late = 0; laterep = 0; latefull = 0; xcross = 0; xcalc = 0; failed = ""; running = ""
        for (i = 1; i <= nrun[p]; i++) if (rcross[p, i] == 1 && rfull[p, i] == 0) { ci = i; break }
        if (ci == 0) for (i = 1; i <= nrun[p]; i++) if (rcross[p, i] == 1) { ci = i; break }
        for (i = 1; i <= nrun[p]; i++) {
          if (i == ci) continue
          if (rcross[p, i] == 1 && rfull[p, i] == 0) { xcross++; xcalc += rcalc[p, i]; continue }
          if (rok[p, i] == 1 && rfull[p, i] == 0 && rf[p, i] != "-") regular[++nreg] = rsecs[p, i]
          if (i > ci && rcalc[p, i] > 0) { if (rfull[p, i] == 1) latefull += rcalc[p, i]; else { late += rcalc[p, i]; laterep += rrep[p, i] } }
        }
        for (i = 1; i <= nrun[p]; i++) {
          if (rok[p, i] == 1) continue
          if (i < nrun[p]) failed = failed " " rd[p, i]
          else if (rage[p, i] >= 43200) failed = failed " " rd[p, i] " (no newer sync for " hdur(rage[p, i]) ")"
          else running = rd[p, i] " (last log line " hdur(rage[p, i]) " ago)"
        }
        synced = (hafter[p] == 1 || ci > 0)
        if (!synced) {
          nns++; notsynced = notsynced " " p
          emit("NOTE", p, "not synced since " B " yet (last h marker " lasth[p] ")" (running != "" ? ", sync in progress since " running : ""))
          continue
        }
        txt = ""
        if (total[p] == 0) txt = "no " c " metrics"
        else if (after[p] < total[p]) emit("WARN", p, "markers: only " after[p] "/" total[p] " " c " keys computed since " B " (first " first[p] ")")
        else txt = "markers " after[p] "/" total[p] " (first " first[p] ")"
        if (tprev[p] > 0 && tconcl[p] < tprev[p]) {
          if (after[p] < total[p] || total[p] == 0) emit("WARN", p, "TSDB: concluded " c " point missing in " (tprev[p] - tconcl[p]) " of " tprev[p] " tables: " gaps[p])
          else emit("NOTE", p, "TSDB: no concluded " c " point in " (tprev[p] - tconcl[p]) " of " tprev[p] " tables (computed OK - no activity?): " gaps[p])
        }
        txt = txt "; TSDB concluded point in " tconcl[p] " tables (new partial in " tnew[p] ")"
        if (ci > 0) {
          if (rdue[p, ci] != 1) emit("WARN", p, "boundary sync " rd[p, ci] " TS range " rf[p, ci] " - " rt[p, ci] " does not cross a " c " boundary (clock/offset?)")
          if (rcalc[p, ci] == 0 && total[p] > 0) emit("WARN", p, "boundary sync " rd[p, ci] " computed 0 " c " metrics (skips " rskip[p, ci] ")")
          else if (rcalc[p, ci] < total[p]) emit("NOTE", p, "boundary sync " rd[p, ci] " computed " rcalc[p, ci] " of " total[p] " " c " metrics (skips " rskip[p, ci] ", the rest repaired later?)")
          if (rok[p, ci] != 1 && (ci < nrun[p] || rage[p, ci] >= 43200)) emit("WARN", p, "boundary sync " rd[p, ci] " has no Sync success")
          if (c == "d" && rok[p, ci] == 1 && (rtags[p, ci] != 1 || rcols[p, ci] < 1)) emit("WARN", p, "boundary sync " rd[p, ci] ": tags " rtags[p, ci] " columns " rcols[p, ci] " (expected 1 / >=1)")
          if (rrep[p, ci] > 0) emit("NOTE", p, "boundary sync " rd[p, ci] " repaired " rrep[p, ci] " " c " period(s) (marker missing)")
          med = median(regular, nreg)
          txt = txt "; boundary sync " rd[p, ci] " (TS " rf[p, ci] " - " rt[p, ci] ") " c "-calcs " rcalc[p, ci] (rfull[p, ci] == 1 ? " [full recompute]" : "") " took " rtm[p, ci] (med > 0 ? " (regular median " hdur(med) ")" : "")
          if (rok[p, ci] == 1) { allc[++nc] = rsecs[p, ci]; if (med > 0) allm[++nm] = med }
        } else txt = txt "; boundary sync not in gha_logs (pruned / synced before the logs window)"
        if (xcross > 0) emit("NOTE", p, xcross " more boundary-crossing sync(s) with " xcalc " " c " calcs (an affiliations/full recompute run in between?)")
        if (late > 0) emit("NOTE", p, late " " c " calcs in later regular syncs (repairs " laterep ")")
        if (latefull > 0) emit("NOTE", p, latefull " " c " calcs in later full-recompute syncs (affiliations / RESETTSDB)")
        if (failed != "") emit("WARN", p, "sync(s) without Sync success:" failed)
        if (running != "" && ci > 0 && rok[p, ci] == 1) emit("NOTE", p, "sync in progress: " running)
        if (!bad) emit("OK", p, txt); else if (verbose) print "     [" c "] " p ": " txt
      }
      printf "%s[%s] boundary %s: %d projects, %d OK, %d WARN, %d NOTE, %d not synced yet%s\n", (nwarn ? R : G), c, B, np, nok, nwarn, nnote, nns, N
      if (nns > 0) print "     [" c "] not synced yet:" notsynced
      if (nc > 0) printf "     [%s] boundary syncs: median %s (n=%d) vs regular syncs median %s\n", c, hdur(median(allc, nc)), nc, hdur(median(allm, nm))
      exit (nwarn > 0 ? 1 : 0)
    }
  ' "$TMPD/rows-$c.txt" | while IFS= read -r line; do out "$line"; done
  [ "${PIPESTATUS[0]}" = "1" ] && WARNS=$((WARNS+1))
done
[ "$WARNS" -gt 0 ] && exit 1
exit 0
