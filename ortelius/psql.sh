#!/bin/bash
set -o pipefail
function finish {
    sync_unlock.sh
}
if [ -z "$TRAP" ]
then
  sync_lock.sh || exit -1
  trap finish EXIT
  export TRAP=1
fi
> errors.txt
> run.log
GHA2DB_PROJECT=ortelius PG_DB=ortelius GHA2DB_LOCAL=1 structure 2>>errors.txt | tee -a run.log || exit 1
./devel/db.sh psql ortelius -c "create extension if not exists pgcrypto" || exit 1
GHA2DB_PROJECT=ortelius PG_DB=ortelius GHA2DB_LOCAL=1 gha2db 2017-03-06 0 today now "ortelius,ortelius/azure-infra,ortelius/backstage,ortelius/cli,ortelius/dev-env-setup,ortelius/keptn-config,ortelius/keptn-ortelius-service,ortelius/la-sbom-ledger,ortelius/ms-compitem-crud,ortelius/ms-dep-pkg-cud,ortelius/ms-dep-pkg-r,ortelius/ms-postgres,ortelius/ms-scorecard,ortelius/ms-textfile-crud,ortelius/ms-validate-user,ortelius/ortelius,ortelius/ortelius-charts,ortelius/ortelius-docs,ortelius/ortelius-kubernetes,ortelius/ortelius-python-client,ortelius/ortelius-test-database,ortelius/ortelius-toc,ortelius/ortelius.io,ortelius/outreach" 2>>errors.txt | tee -a run.log || exit 2
GHA2DB_PROJECT=ortelius PG_DB=ortelius GHA2DB_LOCAL=1 GHA2DB_MGETC=y GHA2DB_SKIPTABLE=1 GHA2DB_INDEX=1 structure 2>>errors.txt | tee -a run.log || exit 4
GHA2DB_PROJECT=ortelius PG_DB=ortelius ./shared/setup_repo_groups.sh 2>>errors.txt | tee -a run.log || exit 5
GHA2DB_PROJECT=ortelius PG_DB=ortelius ./shared/import_affs.sh 2>>errors.txt | tee -a run.log || exit 6
GHA2DB_PROJECT=ortelius PG_DB=ortelius ./shared/setup_scripts.sh 2>>errors.txt | tee -a run.log || exit 7
GHA2DB_PROJECT=ortelius PG_DB=ortelius ./shared/get_repos.sh 2>>errors.txt | tee -a run.log || exit 8
GHA2DB_PROJECT=ortelius PG_DB=ortelius GHA2DB_LOCAL=1 vars || exit 9
./devel/ro_user_grants.sh ortelius || exit 10
./devel/psql_user_grants.sh devstats_team ortelius || exit 11
