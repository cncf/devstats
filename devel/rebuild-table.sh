#!/usr/bin/env bash
set -euo pipefail

if [ -z "$1" ] || [ -z "$2" ]
then
  echo "Usage: $0 <DATABASE_NAME> <SCHEMA.TABLE_NAME>"
  echo "Example: $0 mydb mytable"
  exit 1
fi

SCHEMA="public"
DB="$1"
TABLE="$2"

# Where to store the backup dump (custom format)
DUMP_FILE="${PWD}/${DB}_${SCHEMA}_${TABLE}_rebuild_$(date +%Y%m%d_%H%M%S).dump"

echo "== Precheck: show live vs dropped slots =="
psql -d "$DB" -v ON_ERROR_STOP=1 -Atc "
SELECT
  n.nspname || '.' || c.relname,
  count(*) FILTER (WHERE a.attnum > 0 AND NOT a.attisdropped) AS live_cols,
  count(*) FILTER (WHERE a.attnum > 0 AND a.attisdropped)     AS dropped_slots,
  count(*) FILTER (WHERE a.attnum > 0)                        AS total_slots
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_attribute a ON a.attrelid = c.oid
WHERE n.nspname = '$SCHEMA' AND c.relname = '$TABLE'
GROUP BY 1;
"

echo "== Step 1: Dump ONLY ${SCHEMA}.${TABLE} (schema + data + indexes/constraints) to: $DUMP_FILE =="
pg_dump -d "$DB" -Fc -t "${SCHEMA}.${TABLE}" -f "$DUMP_FILE"

function finish {
    rm -f "$DUMP_FILE"
}
trap finish EXIT

echo "== Step 2: Drop+recreate ONLY ${SCHEMA}.${TABLE} from the dump (atomic) =="
# --clean --if-exists: drop the dumped objects first (table, indexes, sequences owned by it, etc.)
# --single-transaction: all-or-nothing (if DROP fails due to dependencies, nothing changes)
pg_restore -d "$DB" --clean --if-exists --single-transaction -t "${SCHEMA}.${TABLE}" "$DUMP_FILE"

echo "== Step 3: Analyze =="
psql -d "$DB" -v ON_ERROR_STOP=1 -c "ANALYZE ${SCHEMA}.\"${TABLE}\";"

echo "DONE. Backup dump kept at: $DUMP_FILE"

