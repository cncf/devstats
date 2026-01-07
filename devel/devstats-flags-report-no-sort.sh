#!/usr/bin/env bash
# DevStats flags status report:
# - provisioned: must exist in all stage DBs (report missing; DEBUG=1 prints dt + since for all)
# - devstats_running: report only DBs that have it (adds age; never list inactive DBs, even in DEBUG=1)
# - devstats DB: report any gha_computed.metric like '%lock%' (adds locked_since)

set -u
set -o pipefail

usage() {
  echo "Usage: $0 {prod|test}" >&2
  echo "Optional env vars:" >&2
  echo "  DEBUG=1" >&2
  echo "  POD=devstats-postgres-0" >&2
  echo "  CONTAINER=devstats-postgres" >&2
}

STAGE="${1:-}"
if [[ -z "$STAGE" || ! "$STAGE" =~ ^(prod|test)$ ]]; then
  usage
  exit 1
fi

DEBUG="${DEBUG:-0}"

# Per your request: assume kubectl (no 'k' alias usage)
KCMD="kubectl"

NS="devstats-${STAGE}"
POD="${POD:-devstats-postgres-0}"
CONTAINER="${CONTAINER:-devstats-postgres}"

DB_FILE="devel/all_${STAGE}_dbs.txt"
if [[ ! -f "$DB_FILE" ]]; then
  echo "ERROR: Missing DB list file: $DB_FILE" >&2
  echo "Run this from the devstats repo root (where 'devel/' exists)." >&2
  exit 2
fi

# Read DBs (space/newline separated) and de-duplicate while preserving order
declare -a DBS=()
declare -A SEEN=()
while IFS= read -r db; do
  [[ -z "$db" ]] && continue
  if [[ -z "${SEEN[$db]:-}" ]]; then
    DBS+=("$db")
    SEEN["$db"]=1
  fi
done < <(tr ' \t' '\n' < "$DB_FILE" | sed '/^$/d')

if [[ "${#DBS[@]}" -eq 0 ]]; then
  echo "ERROR: DB list is empty in $DB_FILE" >&2
  exit 3
fi

# Globals set by psql_exec()
PSQL_OUT=""
PSQL_ERR=""
PSQL_RC=0

psql_exec() {
  local db="$1"
  local sql="$2"

  PSQL_OUT=""
  PSQL_ERR=""
  PSQL_RC=0

  local tmp_out tmp_err
  tmp_out="$(mktemp)"
  tmp_err="$(mktemp)"

  # -A: unaligned, -t: tuples-only, -q: quiet
  # ON_ERROR_STOP makes SQL errors return non-zero
  $KCMD exec -n "$NS" "$POD" -c "$CONTAINER" -- \
    psql -Atq -v ON_ERROR_STOP=1 "$db" -c "$sql" \
    >"$tmp_out" 2>"$tmp_err"

  PSQL_RC=$?
  PSQL_OUT="$(cat "$tmp_out" 2>/dev/null || true)"
  PSQL_ERR="$(cat "$tmp_err" 2>/dev/null || true)"

  rm -f "$tmp_out" "$tmp_err"
  return "$PSQL_RC"
}

now_utc() {
  date -u +"%Y-%m-%d %H:%M:%S UTC"
}

echo "DevStats flags report"
echo "  Stage:        $STAGE"
echo "  Namespace:    $NS"
echo "  Pod:          $POD (container: $CONTAINER)"
echo "  kubectl:      $KCMD"
echo "  DB list:      $DB_FILE (${#DBS[@]} DBs)"
echo "  Generated:    $(now_utc)"
echo

# Collect results
declare -a MISSING_PROVISIONED=()
declare -a PROVISIONED_DEBUG_LINES=()   # "db|dt|since" or "db|MISSING|"
declare -a RUNNING_LINES=()             # always only DBs that have devstats_running: "db|dt|age"
declare -a QUERY_ERRORS=()              # debug-friendly

# One query per DB to fetch latest provisioned + latest devstats_running, including interval since/age
SQL_BOTH_METRICS=$'WITH m AS (\n'\
$'  SELECT metric, dt,\n'\
$'         row_number() OVER (PARTITION BY metric ORDER BY dt DESC) AS rn\n'\
$'  FROM gha_computed\n'\
$'  WHERE metric IN (\'provisioned\', \'devstats_running\')\n'\
$')\n'\
$'SELECT metric, dt, (now() - dt) AS age\n'\
$'FROM m WHERE rn = 1\n'\
$'ORDER BY metric;\n'

for db in "${DBS[@]}"; do
  prov_dt=""
  prov_since=""
  run_dt=""
  run_age=""

  if psql_exec "$db" "$SQL_BOTH_METRICS"; then
    if [[ -n "$PSQL_OUT" ]]; then
      while IFS='|' read -r metric dt age; do
        case "$metric" in
          provisioned)
            prov_dt="$dt"
            prov_since="$age"
            ;;
          devstats_running)
            run_dt="$dt"
            run_age="$age"
            ;;
        esac
      done <<<"$PSQL_OUT"
    fi
  else
    # Treat as missing provisioned (can't confirm); keep error for DEBUG
    QUERY_ERRORS+=("$db: failed to query gha_computed (rc=$PSQL_RC): ${PSQL_ERR//$'\n'/ }")
  fi

  # provisioned must exist everywhere
  if [[ -z "$prov_dt" ]]; then
    MISSING_PROVISIONED+=("$db")
    if [[ "$DEBUG" == "1" ]]; then
      PROVISIONED_DEBUG_LINES+=("$db|MISSING|")
    fi
  else
    if [[ "$DEBUG" == "1" ]]; then
      PROVISIONED_DEBUG_LINES+=("$db|$prov_dt|$prov_since")
    fi
  fi

  # devstats_running: list only DBs that have it (never list inactive DBs)
  if [[ -n "$run_dt" ]]; then
    RUNNING_LINES+=("$db|$run_dt|$run_age")
  fi
done

echo "== Provisioned flag (metric='provisioned') =="
if [[ "$DEBUG" == "1" ]]; then
  # Print all DBs with dt or MISSING, plus "since"
  printf "%-28s %-30s %s\n" "DB" "provisioned_dt" "since"
  printf "%-28s %-30s %s\n" "----------------------------" "------------------------------" "------------------------------"
  for line in "${PROVISIONED_DEBUG_LINES[@]}"; do
    db="${line%%|*}"
    rest="${line#*|}"
    dt="${rest%%|*}"
    since="${rest#*|}"
    printf "%-28s %-30s %s\n" "$db" "$dt" "$since"
  done
  echo
fi

if [[ "${#MISSING_PROVISIONED[@]}" -eq 0 ]]; then
  echo "All DBs have 'provisioned'."
else
  echo "DBs missing 'provisioned' (${#MISSING_PROVISIONED[@]}):"
  for db in "${MISSING_PROVISIONED[@]}"; do
    echo "  - $db"
  done
fi
echo

echo "== Projects with devstats_running (metric='devstats_running') =="
if [[ "${#RUNNING_LINES[@]}" -eq 0 ]]; then
  echo "None."
else
  if [[ "$DEBUG" == "1" ]]; then
    printf "%-28s %-30s %s\n" "DB" "devstats_running_dt" "age"
    printf "%-28s %-30s %s\n" "----------------------------" "------------------------------" "------------------------------"
    for line in "${RUNNING_LINES[@]}"; do
      db="${line%%|*}"
      rest="${line#*|}"
      dt="${rest%%|*}"
      age="${rest#*|}"
      printf "%-28s %-30s %s\n" "$db" "$dt" "$age"
    done
  else
    # Non-debug: still include age (requested)
    printf "%-28s %s\n" "DB" "age"
    printf "%-28s %s\n" "----------------------------" "------------------------------"
    for line in "${RUNNING_LINES[@]}"; do
      db="${line%%|*}"
      rest="${line#*|}"
      # dt is present but not printed in non-debug
      age="${rest#*|}"  # rest = dt|age -> take after last '|'
      printf "%-28s %s\n" "$db" "$age"
    done
  fi
fi
echo

echo "== devstats DB locks (gha_computed.metric like '%lock%') =="
SQL_LOCKS="select metric, dt, (now() - dt) as locked_since from gha_computed where metric like '%lock%' order by dt desc;"
if psql_exec "devstats" "$SQL_LOCKS"; then
  if [[ -z "$PSQL_OUT" ]]; then
    echo "No lock metrics found."
  else
    printf "%-40s %-30s %s\n" "metric" "dt" "locked_since"
    printf "%-40s %-30s %s\n" "----------------------------------------" "------------------------------" "------------------------------"
    while IFS='|' read -r metric dt locked_since; do
      printf "%-40s %-30s %s\n" "$metric" "$dt" "$locked_since"
    done <<<"$PSQL_OUT"
  fi
else
  echo "ERROR: failed to query devstats DB for locks (rc=$PSQL_RC)." >&2
  echo "  $PSQL_ERR" >&2
fi
echo

if [[ "$DEBUG" == "1" && "${#QUERY_ERRORS[@]}" -gt 0 ]]; then
  echo "== DEBUG: Query errors encountered =="
  for e in "${QUERY_ERRORS[@]}"; do
    echo "  - $e"
  done
  echo
fi

