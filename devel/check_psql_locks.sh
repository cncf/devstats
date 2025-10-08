#!/bin/bash
# STAGE=prod N=3 DB=grpc2 ./devel/check_psql_locks.sh
if [ -z "${STAGE}" ]
then
  export STAGE="prod"
fi
if [ -z "${N}" ]
then
  export N="0"
fi
if [ -z "${DB}" ]
then
  export DB="gha"
fi
kubectl exec -in "devstats-${STAGE}" "devstats-postgres-${N}" -- psql "${DB}" -c "SELECT pid, usename, application_name, state, wait_event_type, wait_event, age(clock_timestamp(), xact_start) AS xact_age, query FROM pg_stat_activity WHERE wait_event_type = 'Lock' ORDER BY xact_start"
