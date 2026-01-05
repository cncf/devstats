#!/bin/bash
# kenv=test|prod (for DBs list)
# kenv2=test|prod (for K8s namespace)
if [ -z "$1" ]
then
  echo "$0: at least one SQL script required"
  exit 1
fi
if [ -z "${kenv}" ]
then
  echo "$0: you need to specify kenv=test|prod"
  exit 2
fi
if ( [ ! -z "${kenv2}" ] && [ ! "${kenv}" = "${kenv2}" ] )
then
  echo "overwritting kenv $kenv -> $kenv2"
else
  export kenv2="${kenv}"
fi
if [ "${kenv}" = "test" ]
then
  export TEST_SERVER=1
  export member=$(kubectl exec -in devstats-${kenv2} devstats-postgres-0 -c devstats-postgres -- patronictl list -f json | jq -rS '.[]  | select(.Role == "Leader") | .Member')
  echo "R/W member on ${kenv} is ${member}"
elif [ "${kenv}" = "prod" ]
then
  export PROD_SERVER=1
  export member=$(kubectl exec -in devstats-${kenv2} devstats-postgres-0 -c devstats-postgres -- patronictl list -f json | jq -rS '.[]  | select(.Role == "Leader") | .Member')
  echo "R/W member on ${kenv} is ${member}"
else
  echo "kenv must be test or prod, got: ${kenv}"
  exit 3
fi
. ./devel/all_dbs.sh || exit 2
for db in $all
do
  for sql in $*
  do
    echo "Execute script '$sql' on '$db' database"
    kubectl exec -in "devstats-${kenv2}" "${member}" -c devstats-postgres -- psql "$db" < "$sql"
  done
done
echo 'OK'

