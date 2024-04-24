#!/bin/bash
# example: DB=opentelemetry ./run_sql.sh con.sql {{n}} 1 {{from}} '2024-04-01' {{to}} '2024-04-08'
if [ -z "$1" ]
then
  echo "$0: you need to specify filename as a 1st argument: DB=gha $0 filename.sql [other args]"
  exit 1
fi
if [ -z "$DB" ]
then
  echo "$0: you need to specify a database: DB=gha $0 filename.sql [other args]"
  exit 2
fi
runq.sh "${1}" ${@:2} > "${1}.runq" && kubectl exec -in devstats-prod devstats-postgres-0 -- psql "${DB}" < "${1}.runq"
