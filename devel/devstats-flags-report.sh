#!/usr/bin/env bash
# DevStats flags + activity report:
# - provisioned: must exist in all stage DBs (report missing; DEBUG=1 prints dt+since for all, sorted by since desc)
# - devstats_running: report only DBs that have it (prints age, sorted by age desc; never list inactive DBs, even in DEBUG=1)
# - devstats DB: report any gha_computed.metric like '%lock%' (prints locked_since, sorted by locked_since desc)
# - activity checks (should return no rows):
#     * deadlocks (pg_stat_database.deadlocks > 0) for stage DBs (+ devstats)
#     * blocked sessions (cardinality(pg_blocking_pids(pid)) > 0)
#     * blocking sessions (the blockers for the blocked sessions)
# - column-slot limit checks (per DB):
#     * tables where total_attribute_slots > COLS_SLOTS_THRESHOLD (default 1400)
#       output: db: table(total),table(total)...

set -u
set -o pipefail

usage() {
  echo "Usage: $0 {prod|test}" >&2
  echo "Optional env vars:" >&2
  echo "  DEBUG=1" >&2
  echo "  POD=devstats-postgres-0" >&2
  echo "  CONTAINER=devstats-postgres" >&2
  echo "  COLS_SLOTS_THRESHOLD=1400   # warn if total_attribute_slots exceeds this" >&2
}

STAGE="${1:-}"
if [[ -z "$STAGE" || ! "$STAGE" =~ ^(prod|test)$ ]]; then
  usage
  exit 1
fi

DEBUG="${DEBUG:-0}"

# Per requirement: assume kubectl
KCMD="kubectl"

NS="devstats-${STAGE}"
POD="${POD:-devstats-postgres-0}"
CONTAINER="${CONTAINER:-devstats-postgres}"

COLS_SLOTS_THRESHOLD="${COLS_SLOTS_THRESHOLD:-1400}"
if ! [[ "$COLS_SLOTS_THRESHOLD" =~ ^[0-9]+$ ]]; then
  echo "ERROR: COLS_SLOTS_THRESHOLD must be an integer, got: $COLS_SLOTS_THRESHOLD" >&2
  exit 1
fi

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

sql_quote_literal() {
  # SQL literal-quote a string: ' -> ''
  local s="$1"
  s="${s//\'/\'\'}"
  printf "'%s'" "$s"
}

build_in_list() {
  # Build: 'a','b','c'
  local out=""
  local item
  for item in "$@"; do
    out+=$(sql_quote_literal "$item")
    out+=","
  done
  out="${out%,}"
  printf "%s" "$out"
}

print_psql_table() {
  # header: pipe-separated header line
  # data: psql -At output (pipe-separated rows)
  local header="$1"
  local data="$2"
  if [[ -z "$data" ]]; then
    return 0
  fi
  if command -v column >/dev/null 2>&1; then
    { echo "$header"; echo "$data"; } | column -t -s'|'
  else
    echo "$header"
    echo "$data"
  fi
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

# Store sortable lines as: "<age_seconds>|<db>|<dt>|<interval>"
declare -a PROVISIONED_DEBUG_LINES=()   # includes ALL DBs in DEBUG=1; sorted by since desc
declare -a RUNNING_LINES=()             # includes ONLY DBs with devstats_running; sorted by age desc
declare -a QUERY_ERRORS=()
declare -a ACTIVITY_ERRORS=()
declare -a COLSLOT_ERRORS=()

# One query per DB to fetch latest provisioned + latest devstats_running
# Output columns: metric | dt | age_s | age_interval
SQL_BOTH_METRICS=$'WITH m AS (\n'\
$'  SELECT metric, dt,\n'\
$'         row_number() OVER (PARTITION BY metric ORDER BY dt DESC) AS rn\n'\
$'  FROM gha_computed\n'\
$'  WHERE metric IN (\'provisioned\', \'devstats_running\')\n'\
$')\n'\
$'SELECT metric,\n'\
$'       dt,\n'\
$'       extract(epoch from (now() - dt))::bigint AS age_s,\n'\
$'       (now() - dt) AS age\n'\
$'FROM m WHERE rn = 1\n'\
$'ORDER BY metric;\n'

for db in "${DBS[@]}"; do
  prov_dt=""
  prov_since=""
  prov_since_s="-1"

  run_dt=""
  run_age=""
  run_age_s=""

  if psql_exec "$db" "$SQL_BOTH_METRICS"; then
    if [[ -n "$PSQL_OUT" ]]; then
      while IFS='|' read -r metric dt age_s age; do
        case "$metric" in
          provisioned)
            prov_dt="$dt"
            prov_since="$age"
            prov_since_s="$age_s"
            ;;
          devstats_running)
            run_dt="$dt"
            run_age="$age"
            run_age_s="$age_s"
            ;;
        esac
      done <<<"$PSQL_OUT"
    fi
  else
    QUERY_ERRORS+=("$db: failed to query gha_computed (rc=$PSQL_RC): ${PSQL_ERR//$'\n'/ }")
  fi

  # provisioned must exist everywhere
  if [[ -z "$prov_dt" ]]; then
    MISSING_PROVISIONED+=("$db")
    if [[ "$DEBUG" == "1" ]]; then
      PROVISIONED_DEBUG_LINES+=("-1|$db|MISSING|")
    fi
  else
    if [[ "$DEBUG" == "1" ]]; then
      PROVISIONED_DEBUG_LINES+=("${prov_since_s}|$db|$prov_dt|$prov_since")
    fi
  fi

  # devstats_running: list only DBs that have it (never list inactive DBs)
  if [[ -n "$run_dt" ]]; then
    RUNNING_LINES+=("${run_age_s}|$db|$run_dt|$run_age")
  fi
done

echo "== Provisioned flag (metric='provisioned') =="
if [[ "$DEBUG" == "1" ]]; then
  printf "%-28s %-30s %s\n" "DB" "provisioned_dt" "since"
  printf "%-28s %-30s %s\n" "----------------------------" "------------------------------" "------------------------------"

  while IFS='|' read -r since_s db dt since; do
    printf "%-28s %-30s %s\n" "$db" "$dt" "$since"
  done < <(printf "%s\n" "${PROVISIONED_DEBUG_LINES[@]}" | sort -t'|' -k1,1nr)

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

    while IFS='|' read -r age_s db dt age; do
      printf "%-28s %-30s %s\n" "$db" "$dt" "$age"
    done < <(printf "%s\n" "${RUNNING_LINES[@]}" | sort -t'|' -k1,1nr)
  else
    printf "%-28s %s\n" "DB" "age"
    printf "%-28s %s\n" "----------------------------" "------------------------------"

    while IFS='|' read -r age_s db dt age; do
      printf "%-28s %s\n" "$db" "$age"
    done < <(printf "%s\n" "${RUNNING_LINES[@]}" | sort -t'|' -k1,1nr)
  fi
fi
echo

echo "== devstats DB locks (gha_computed.metric like '%lock%') =="
SQL_LOCKS=$'select metric,\n'\
$'       dt,\n'\
$'       extract(epoch from (now() - dt))::bigint as locked_since_s,\n'\
$'       (now() - dt) as locked_since\n'\
$'from gha_computed\n'\
$'where metric like \'%lock%\'\n'\
$'order by locked_since_s desc;\n'

if psql_exec "devstats" "$SQL_LOCKS"; then
  if [[ -z "$PSQL_OUT" ]]; then
    echo "No lock metrics found."
  else
    printf "%-40s %-30s %s\n" "metric" "dt" "locked_since"
    printf "%-40s %-30s %s\n" "----------------------------------------" "------------------------------" "------------------------------"
    while IFS='|' read -r metric dt locked_since_s locked_since; do
      printf "%-40s %-30s %s\n" "$metric" "$dt" "$locked_since"
    done <<<"$PSQL_OUT"
  fi
else
  echo "ERROR: failed to query devstats DB for locks (rc=$PSQL_RC)." >&2
  echo "  $PSQL_ERR" >&2
fi
echo

# -------- Activity checks across stage DBs (+ devstats) --------

# Build list of DBs to check for cross-DB pg_stat_activity filters: stage DBs + devstats
declare -a CHECK_DBS=()
declare -A CHECK_SEEN=()
for db in "${DBS[@]}" "devstats"; do
  if [[ -z "${CHECK_SEEN[$db]:-}" ]]; then
    CHECK_DBS+=("$db")
    CHECK_SEEN["$db"]=1
  fi
done

CHECK_DBS_IN="$(build_in_list "${CHECK_DBS[@]}")"

if [[ "$DEBUG" == "1" ]]; then
  echo "== Deadlocks (pg_stat_database.deadlocks > 0) =="
  SQL_DEADLOCKS=$(cat <<SQL
select datname, deadlocks, stats_reset
from pg_stat_database
where datname in (${CHECK_DBS_IN})
  and deadlocks > 0
order by deadlocks desc, datname;
SQL
)

  if psql_exec "devstats" "$SQL_DEADLOCKS"; then
    if [[ -z "$PSQL_OUT" ]]; then
      echo "No deadlocks reported (since stats_reset)."
    else
      print_psql_table "db|deadlocks|stats_reset" "$PSQL_OUT"
    fi
  else
    ACTIVITY_ERRORS+=("deadlocks query failed (rc=$PSQL_RC): ${PSQL_ERR//$'\n'/ }")
    echo "ERROR: failed to query deadlocks (cannot verify)." >&2
  fi
  echo
fi

echo "== Blocked sessions (waiting on locks) =="
# Should return 0 rows
SQL_BLOCKED=$(cat <<SQL
SELECT
  datname,
  pid,
  usename,
  application_name,
  client_addr,
  state,
  now() - xact_start  AS xact_age,
  now() - query_start AS runtime,
  pg_blocking_pids(pid) AS blocking_pids,
  left(query, 200) AS query
FROM pg_stat_activity
WHERE datname in (${CHECK_DBS_IN})
  AND cardinality(pg_blocking_pids(pid)) > 0
ORDER BY xact_age DESC NULLS LAST, runtime DESC;
SQL
)

if psql_exec "devstats" "$SQL_BLOCKED"; then
  if [[ -z "$PSQL_OUT" ]]; then
    echo "No blocked sessions found."
  else
    print_psql_table "db|pid|usename|app|client_addr|state|xact_age|runtime|blocking_pids|query" "$PSQL_OUT"
  fi
else
  ACTIVITY_ERRORS+=("blocked sessions query failed (rc=$PSQL_RC): ${PSQL_ERR//$'\n'/ }")
  echo "ERROR: failed to query blocked sessions (cannot verify)." >&2
fi
echo

echo "== Blocking sessions (blockers) =="
# Should return 0 rows
SQL_BLOCKERS=$(cat <<SQL
WITH blocked AS (
  SELECT
    datname AS blocked_db,
    unnest(pg_blocking_pids(pid)) AS blocking_pid
  FROM pg_stat_activity
  WHERE datname in (${CHECK_DBS_IN})
    AND cardinality(pg_blocking_pids(pid)) > 0
)
SELECT
  b.blocked_db,
  a.pid,
  a.usename,
  a.application_name,
  a.client_addr,
  a.state,
  now() - a.xact_start  AS xact_age,
  now() - a.query_start AS runtime,
  a.datname AS blocker_db,
  left(a.query, 200) AS query
FROM pg_stat_activity a
JOIN (SELECT DISTINCT blocked_db, blocking_pid FROM blocked) b
  ON a.pid = b.blocking_pid
ORDER BY xact_age DESC NULLS LAST, runtime DESC;
SQL
)

if psql_exec "devstats" "$SQL_BLOCKERS"; then
  if [[ -z "$PSQL_OUT" ]]; then
    echo "No blocking sessions found."
  else
    print_psql_table "blocked_db|pid|usename|app|client_addr|state|xact_age|runtime|blocker_db|query" "$PSQL_OUT"
  fi
else
  ACTIVITY_ERRORS+=("blocking sessions query failed (rc=$PSQL_RC): ${PSQL_ERR//$'\n'/ }")
  echo "ERROR: failed to query blocking sessions (cannot verify)." >&2
fi
echo

# -------- Per-DB: tables close to 1600 column-slot limit --------

echo "== Tables close to 1600-column limit (total_attribute_slots > ${COLS_SLOTS_THRESHOLD}) =="
echo "Fix: [NS=devstats-prod] devel/rebuild-table.sh db-name table_name"
SQL_COLSLOTS=$(cat <<SQL
SELECT
  n.nspname AS schema,
  c.relname AS table,
  count(*) AS total_attribute_slots,
  count(*) FILTER (WHERE a.attisdropped) AS dropped_slots,
  count(*) FILTER (WHERE a.attnum > 0 AND NOT a.attisdropped) AS live_columns
FROM pg_attribute a
JOIN pg_class c ON c.oid = a.attrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r','p')
  AND a.attnum > 0
GROUP BY 1,2
HAVING count(*) > ${COLS_SLOTS_THRESHOLD}
ORDER BY total_attribute_slots DESC, dropped_slots DESC;
SQL
)

found_cols_slots=0
for db in "${CHECK_DBS[@]}"; do
  if psql_exec "$db" "$SQL_COLSLOTS"; then
    if [[ -n "$PSQL_OUT" ]]; then
      found_cols_slots=1
      # Build: table(total),table(total)...
      cols_items=()
      while IFS='|' read -r schema table total_slots dropped_slots live_cols; do
        # Match your preferred style: omit "public." prefix, keep schema for non-public.
        if [[ "$schema" == "public" ]]; then
          name="$table"
        else
          name="${schema}.${table}"
        fi
        cols_items+=("${name}(${total_slots})")
      done <<<"$PSQL_OUT"

      cols_joined="$(IFS=,; echo "${cols_items[*]}")"
      echo "${db}: ${cols_joined}"
    fi
  else
    COLSLOT_ERRORS+=("$db: column-slot query failed (rc=$PSQL_RC): ${PSQL_ERR//$'\n'/ }")
  fi
done

if [[ "$found_cols_slots" -eq 0 ]]; then
  echo "None."
fi
echo

if [[ "$DEBUG" == "1" && "${#QUERY_ERRORS[@]}" -gt 0 ]]; then
  echo "== DEBUG: per-DB gha_computed query errors encountered =="
  for e in "${QUERY_ERRORS[@]}"; do
    echo "  - $e"
  done
  echo
fi

if [[ "$DEBUG" == "1" && "${#ACTIVITY_ERRORS[@]}" -gt 0 ]]; then
  echo "== DEBUG: activity query errors encountered =="
  for e in "${ACTIVITY_ERRORS[@]}"; do
    echo "  - $e"
  done
  echo
fi

if [[ "$DEBUG" == "1" && "${#COLSLOT_ERRORS[@]}" -gt 0 ]]; then
  echo "== DEBUG: column-slot query errors encountered =="
  for e in "${COLSLOT_ERRORS[@]}"; do
    echo "  - $e"
  done
  echo
fi

