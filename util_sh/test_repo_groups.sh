#!/bin/bash
if [ -z "$N" ]
then
  echo "$0: specify patroni node number: N=n"
  kubectl exec -itn devstats-prod devstats-postgres-0 -- patronictl list
  exit 1
fi
if [ -z "$DB" ]
then
  echo "$0: specify db with DB=db"
  kubectl exec -itn devstats-prod devstats-postgres-0 -- psql -c '\l'
  exit 2
fi
kubectl exec -itn devstats-prod devstats-postgres-$N -- pg_dump $DB --table gha_repos > "${DB}_gha_repos.sql"
kubectl exec -itn devstats-prod devstats-postgres-$N -- pg_dump $DB --table gha_repo_groups > "${DB}_gha_repo_groups.sql"
kubectl exec -itn devstats-prod devstats-postgres-$N -- dropdb -f --if-exists "${DB}_tmp" 1>/dev/null 2>/dev/null
kubectl exec -itn devstats-prod devstats-postgres-$N -- createdb "${DB}_tmp"
kubectl exec -in devstats-prod devstats-postgres-$N -- psql "${DB}_tmp" < "${DB}_gha_repos.sql"
kubectl exec -in devstats-prod devstats-postgres-$N -- psql "${DB}_tmp" < "${DB}_gha_repo_groups.sql"
rm -f "${DB}_gha_repos.sql" "${DB}_gha_repo_groups.sql"
