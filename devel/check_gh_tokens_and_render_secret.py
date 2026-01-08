#!/usr/bin/env python3
import argparse
import base64
import json
import os
import subprocess
import sys
import time
import urllib.request
import urllib.error
from typing import Dict, List, Tuple, Optional

GITHUB_API = "https://api.github.com/rate_limit"

DEFAULT_SECRET_NAME = "github-oauth"
DEFAULT_SECRET_KEY = "GHA2DB_GITHUB_OAUTH.secret"

ENV_TO_NAMESPACE = {
    "devstats-prod": "devstats-prod",
    "devstats-test": "devstats-test",
}

def run_kubectl(args: List[str], *, context: Optional[str] = None) -> bytes:
    cmd = ["kubectl"]
    if context:
        cmd += ["--context", context]
    cmd += args
    try:
        return subprocess.check_output(cmd, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        sys.stderr.write(e.output.decode("utf-8", errors="replace"))
        raise

def get_secret_json(namespace: str, name: str, *, context: Optional[str]) -> Dict:
    raw = run_kubectl(["-n", namespace, "get", "secret", name, "-o", "json"], context=context)
    return json.loads(raw)

def decode_secret_key_b64(secret_obj: Dict, key: str) -> str:
    data = secret_obj.get("data", {})
    if key not in data:
        raise KeyError(f"Secret does not contain data key '{key}'. Available keys: {list(data.keys())}")
    b64 = data[key]
    return base64.b64decode(b64).decode("utf-8", errors="strict").strip()

def split_tokens(csv: str) -> List[str]:
    # Keep order and duplicates; drop empty entries and trim whitespace
    toks = []
    for part in csv.split(","):
        t = part.strip()
        if t:
            toks.append(t)
    return toks

def redact_token(tok: str) -> str:
    if len(tok) <= 16:
        return tok
    return tok[:8] + "…" + tok[-6:]

def github_check_token(token: str, timeout_s: float) -> Tuple[bool, int, Optional[int], Optional[int], Optional[str]]:
    """
    Returns:
      usable(bool), http_status(int), core_remaining(Optional[int]), core_limit(Optional[int]), note(Optional[str])
    Logic:
      - 200: usable=yes, parse remaining/limit if possible
      - 401: usable=no
      - other HTTP codes: treat as usable=yes (token is accepted but may be rate-limited/forbidden); note included
    """
    req = urllib.request.Request(
        GITHUB_API,
        method="GET",
        headers={
            # "Bearer" matches what oauth2 libs use (also works for classic PATs).
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "User-Agent": "devstats-gh-token-check",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout_s) as resp:
            status = resp.getcode()
            body = resp.read().decode("utf-8", errors="replace")
            core_remaining = None
            core_limit = None
            note = None
            if status == 200:
                try:
                    js = json.loads(body)
                    core = js.get("resources", {}).get("core", {})
                    core_remaining = core.get("remaining")
                    core_limit = core.get("limit")
                except Exception as e:
                    note = f"warning: could not parse JSON: {e}"
                return True, status, core_remaining, core_limit, note
            # Unexpected but handle
            return status != 401, status, None, None, "non-200 response"
    except urllib.error.HTTPError as e:
        status = e.code
        body = e.read().decode("utf-8", errors="replace")
        if status == 401:
            return False, status, None, None, "Bad credentials"
        # 403 could be rate limit / SSO / forbidden, etc. Token is still “accepted”.
        note = body.strip().replace("\n", " ")[:200] if body else None
        return True, status, None, None, note
    except Exception as e:
        # Network/DNS/timeout etc. Conservatively mark as unusable, but include note.
        return False, 0, None, None, f"error: {e}"

def yaml_escape_double_quotes(s: str) -> str:
    return s.replace("\\", "\\\\").replace('"', '\\"')

def build_secret_yaml_stringdata(namespace: str, name: str, key: str, tokens_csv: str) -> str:
    # Using stringData makes it easy to tweak manually (plaintext!)
    val = yaml_escape_double_quotes(tokens_csv)
    return (
        "apiVersion: v1\n"
        "kind: Secret\n"
        "metadata:\n"
        f"  name: {name}\n"
        f"  namespace: {namespace}\n"
        "type: Opaque\n"
        "stringData:\n"
        f"  {key}: \"{val}\"\n"
    )

def build_secret_yaml_data(namespace: str, name: str, key: str, tokens_csv: str) -> str:
    # data is base64 (less readable, but matches how it’s stored)
    b64 = base64.b64encode(tokens_csv.encode("utf-8")).decode("ascii")
    return (
        "apiVersion: v1\n"
        "kind: Secret\n"
        "metadata:\n"
        f"  name: {name}\n"
        f"  namespace: {namespace}\n"
        "type: Opaque\n"
        "data:\n"
        f"  {key}: {b64}\n"
    )

def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate GitHub tokens from a K8s Secret and generate an updated Secret YAML."
    )
    parser.add_argument("env", choices=sorted(ENV_TO_NAMESPACE.keys()),
                        help="Environment (maps to namespace by default).")
    parser.add_argument("--namespace", default=None,
                        help="Override namespace (default is derived from env).")
    parser.add_argument("--context", default=None,
                        help="kubectl context to use (optional).")
    parser.add_argument("--secret", default=DEFAULT_SECRET_NAME,
                        help=f"Kubernetes Secret name (default: {DEFAULT_SECRET_NAME}).")
    parser.add_argument("--key", default=DEFAULT_SECRET_KEY,
                        help=f"Secret data key containing comma-separated tokens (default: {DEFAULT_SECRET_KEY}).")
    parser.add_argument("--timeout", type=float, default=10.0,
                        help="HTTP timeout seconds per token check (default: 10).")
    parser.add_argument("--sleep", type=float, default=0.15,
                        help="Sleep seconds between token checks to avoid abuse/secondary limits (default: 0.15).")
    parser.add_argument("--redact", action="store_true",
                        help="Redact tokens in output (prints partial token instead of full).")
    parser.add_argument("--include-bad-in-yaml", action="store_true",
                        help="If set, YAML includes ALL tokens (good + bad). Default is only usable tokens.")
    parser.add_argument("--yaml-mode", choices=["stringData", "data"], default="stringData",
                        help="Output YAML mode: stringData (readable) or data (base64). Default: stringData.")
    parser.add_argument("--out", default=None,
                        help="Output YAML file path (default: ./github-oauth.<env>.filtered.yaml).")

    args = parser.parse_args()

    # Make created files private by default (best effort)
    os.umask(0o077)

    namespace = args.namespace or ENV_TO_NAMESPACE[args.env]
    out_path = args.out or f"./github-oauth.{args.env}.filtered.yaml"

    # Fetch and decode tokens
    sec = get_secret_json(namespace, args.secret, context=args.context)
    csv = decode_secret_key_b64(sec, args.key)
    tokens = split_tokens(csv)

    if not tokens:
        sys.stderr.write("No tokens found after parsing the secret value.\n")
        return 2

    sys.stderr.write(f"Namespace: {namespace}\n")
    sys.stderr.write(f"Secret:    {args.secret}\n")
    sys.stderr.write(f"Key:       {args.key}\n")
    sys.stderr.write(f"Tokens:    {len(tokens)}\n\n")

    results = []  # (idx, token, usable, status, remaining, limit, note)
    good_tokens = []
    bad_indices = []

    for i, tok in enumerate(tokens):
        usable, status, rem, lim, note = github_check_token(tok, timeout_s=args.timeout)
        shown = tok if not args.redact else redact_token(tok)
        usable_str = "yes" if usable else "no"
        extra = []
        if status != 0:
            extra.append(f"status={status}")
        else:
            extra.append("status=error")
        if rem is not None and lim is not None:
            extra.append(f"core_remaining={rem}/{lim}")
        if note:
            extra.append(f"note={note}")

        print(f"idx={i}\ttoken={shown}\tusable={usable_str}\t" + "\t".join(extra))

        results.append((i, tok, usable, status, rem, lim, note))

        if usable:
            good_tokens.append(tok)
        else:
            bad_indices.append(i)

        if args.sleep > 0:
            time.sleep(args.sleep)

    sys.stderr.write("\nSummary:\n")
    sys.stderr.write(f"  usable:   {len(good_tokens)}\n")
    sys.stderr.write(f"  unusable: {len(tokens) - len(good_tokens)}\n")
    if bad_indices:
        sys.stderr.write(f"  bad idx:  {bad_indices}\n")

    # Decide what goes into YAML
    final_tokens = tokens if args.include_bad_in_yaml else good_tokens
    final_csv = ",".join(final_tokens)

    if args.yaml_mode == "stringData":
        yaml_text = build_secret_yaml_stringdata(namespace, args.secret, args.key, final_csv)
    else:
        yaml_text = build_secret_yaml_data(namespace, args.secret, args.key, final_csv)

    with open(out_path, "w", encoding="utf-8") as f:
        f.write(yaml_text)

    sys.stderr.write(f"\nWrote YAML to: {out_path}\n")
    sys.stderr.write("Review it, tweak if needed, then apply with:\n")
    sys.stderr.write(f"  kubectl -n {namespace} apply -f {out_path}\n")
    sys.stderr.write("\nNOTE: If this secret is Helm-managed, a future helm upgrade may overwrite manual changes.\n")

    return 0

if __name__ == "__main__":
    raise SystemExit(main())

