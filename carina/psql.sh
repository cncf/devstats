#!/bin/bash
function finish {
    sync_unlock.sh
}
if [ -z "$TRAP" ]
then
  sync_lock.sh || exit -1
  trap finish EXIT
  export TRAP=1
fi
set -o pipefail
> errors.txt
> run.log
GHA2DB_PROJECT=carina PG_DB=carina GHA2DB_LOCAL=1 structure 2>>errors.txt | tee -a run.log || exit 1
./devel/db.sh psql carina -c "create extension if not exists pgcrypto" || exit 1
./devel/db.sh psql carina -c "create extension if not exists hll" || exit 1
GHA2DB_PROJECT=carina PG_DB=carina GHA2DB_LOCAL=1 gha2db 2021-08-18 0 today now 'carina-io' 2>>errors.txt | tee -a run.log || exit 2
GHA2DB_PROJECT=carina PG_DB=carina GHA2DB_LOCAL=1 GHA2DB_MGETC=y GHA2DB_SKIPTABLE=1 GHA2DB_INDEX=1 structure 2>>errors.txt | tee -a run.log || exit 3
GHA2DB_PROJECT=carina PG_DB=carina ./shared/setup_repo_groups.sh 2>>errors.txt | tee -a run.log || exit 4
GHA2DB_PROJECT=carina PG_DB=carina ./shared/import_affs.sh 2>>errors.txt | tee -a run.log || exit 5
GHA2DB_PROJECT=carina PG_DB=carina ./shared/setup_scripts.sh 2>>errors.txt | tee -a run.log || exit 6
GHA2DB_PROJECT=carina PG_DB=carina ./shared/get_repos.sh 2>>errors.txt | tee -a run.log || exit 7
GHA2DB_PROJECT=carina PG_DB=carina GHA2DB_LOCAL=1 vars || exit 8
./devel/ro_user_grants.sh carina || exit 9
./devel/psql_user_grants.sh devstats_team carina || exit 10
