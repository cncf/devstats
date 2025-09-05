#!/bin/bash
if [ -z "${1}" ]
then
  echo "${0}: you need to specify which DB as a 1st argument, for example 'jenkins'"
  exit 1
fi
if [ -z "${STAGE}" ]
then
  export STAGE="test"
fi

if [ -z "${N}" ]
then
  export N='0'
fi

for t in $(kubectl exec -in "devstats-${STAGE}" "devstats-postgres-${N}" -- psql -d "${1}" -At -c "select tablename from pg_tables where schemaname = 'public' AND tablename LIKE 's%'")
do
  echo "table: ${t}"
  ./util_sh/fix_table_by_recreating.sh "${1}" "${t}"
done
