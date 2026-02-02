#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <DATABASE_NAME> <TABLE|SCHEMA.TABLE>"
  echo "Env overrides:"
  echo "  NS=devstats-prod POD=devstats-postgres-0 CONTAINER=devstats-postgres"
  echo "  KUBECTL='kubectl' (or 'k')"
  echo "  POD_DUMP_DIR=/tmp (directory inside pod)"
  exit 1
fi

DB="$1"
TARGET="$2"

# Defaults for your environment (override via env if needed)
KUBECTL="${KUBECTL:-kubectl}"          # or set KUBECTL=k
NS="${NS:-devstats-prod}"
POD="${POD:-devstats-postgres-0}"
CONTAINER="${CONTAINER:-devstats-postgres}"
POD_DUMP_DIR="${POD_DUMP_DIR:-/tmp}"
DBG="${DBG:''}"

# Parse schema.table
if [[ "$TARGET" == *.* ]]; then
  SCHEMA="${TARGET%%.*}"
  TABLE="${TARGET##*.}"
else
  SCHEMA="public"
  TABLE="$TARGET"
fi

# Timestamped dump file names
TS="$(date +%Y%m%d_%H%M%S)"
BASENAME="${DB}_${SCHEMA}_${TABLE}_rebuild_${TS}.dump"
POD_DUMP_FILE="${POD_DUMP_DIR%/}/${BASENAME}"

# Helper to exec in pod
kexec() {
  if [ ! -z "${DBG}" ]
  then
    echo -n "\"$KUBECTL\" exec -n \"$NS\" \"$POD\" -c \"$CONTAINER\" -- \"$@\" --> "
  fi
  "$KUBECTL" exec -n "$NS" "$POD" -c "$CONTAINER" -- "$@"
  if [ ! -z "${DBG}" ]
  then
    echo "$?"
  fi
}

cleanup() {
  # best-effort cleanup inside pod + host
  set +e
  kexec rm -f "$POD_DUMP_FILE" >/dev/null 2>&1
}
trap cleanup EXIT

echo "== Context =="
echo "DB=$DB  TABLE=${SCHEMA}.${TABLE}"
echo "Pod: ns=$NS pod=$POD container=$CONTAINER"
echo

echo "== Precheck: show live vs dropped slots (inside pod) =="
kexec psql -d "$DB" -v ON_ERROR_STOP=1 -Atc "
SELECT
  n.nspname || '.' || c.relname,
  count(*) FILTER (WHERE a.attnum > 0 AND NOT a.attisdropped) AS live_cols,
  count(*) FILTER (WHERE a.attnum > 0 AND a.attisdropped)     AS dropped_slots,
  count(*) FILTER (WHERE a.attnum > 0)                        AS total_slots
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_attribute a ON a.attrelid = c.oid
WHERE n.nspname = '${SCHEMA}' AND c.relname = '${TABLE}'
GROUP BY 1;
"
echo

echo "== Step 1: pg_dump (custom format) inside pod =="
# -Fc: custom format
# -t schema.table: only this table
# -f: write to pod filesystem
kexec pg_dump -d "$DB" -Fc -t "${SCHEMA}.${TABLE}" -f "$POD_DUMP_FILE"
echo

echo "== Step 2: pg_restore (drop+recreate, atomic) inside pod =="
# --clean --if-exists: drop dumped objects first
# --single-transaction: all-or-nothing
# -t schema.table: restore only that table
kexec pg_restore -d "$DB" --clean --if-exists --single-transaction -n "$SCHEMA" -t "$TABLE" "$POD_DUMP_FILE"
echo

echo "== Step 3: ANALYZE (inside pod) =="
kexec psql -d "$DB" -v ON_ERROR_STOP=1 -c "ANALYZE ${SCHEMA}.\"${TABLE}\";"
echo

echo "== Postcheck: show live vs dropped slots (inside pod) =="
kexec psql -d "$DB" -v ON_ERROR_STOP=1 -Atc "
SELECT
  n.nspname || '.' || c.relname,
  count(*) FILTER (WHERE a.attnum > 0 AND NOT a.attisdropped) AS live_cols,
  count(*) FILTER (WHERE a.attnum > 0 AND a.attisdropped)     AS dropped_slots,
  count(*) FILTER (WHERE a.attnum > 0)                        AS total_slots
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_attribute a ON a.attrelid = c.oid
WHERE n.nspname = '${SCHEMA}' AND c.relname = '${TABLE}'
GROUP BY 1;
"
echo

echo "DONE."
