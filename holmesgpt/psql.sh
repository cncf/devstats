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
GHA2DB_PROJECT=holmesgpt PG_DB=holmesgpt GHA2DB_LOCAL=1 structure 2>>errors.txt | tee -a run.log || exit 1
./devel/db.sh psql holmesgpt -c "create extension if not exists pgcrypto" || exit 1
./devel/db.sh psql holmesgpt -c "create extension if not exists hll" || exit 1
./devel/ro_user_grants.sh holmesgpt || exit 2
GHA2DB_PROJECT=holmesgpt PG_DB=holmesgpt GHA2DB_LOCAL=1 gha2db 2024-05-30 0 today now 'HolmesGPT,robusta-dev/holmesgpt,robusta-dev/homebrew-holmesgpt,robusta-dev/holmesgpt-community-toolsets' 2>>errors.txt | tee -a run.log || exit 3
GHA2DB_PROJECT=holmesgpt PG_DB=holmesgpt GHA2DB_LOCAL=1 GHA2DB_MGETC=y GHA2DB_SKIPTABLE=1 GHA2DB_INDEX=1 structure 2>>errors.txt | tee -a run.log || exit 5
GHA2DB_PROJECT=holmesgpt PG_DB=holmesgpt ./shared/setup_repo_groups.sh 2>>errors.txt | tee -a run.log || exit 6
GHA2DB_PROJECT=holmesgpt PG_DB=holmesgpt ./shared/setup_scripts.sh 2>>errors.txt | tee -a run.log || exit 7
GHA2DB_PROJECT=holmesgpt PG_DB=holmesgpt ./shared/get_repos.sh 2>>errors.txt | tee -a run.log || exit 8
GHA2DB_PROJECT=holmesgpt PG_DB=holmesgpt ./shared/import_affs.sh 2>>errors.txt | tee -a run.log || exit 9
GHA2DB_PROJECT=holmesgpt PG_DB=holmesgpt GHA2DB_LOCAL=1 vars || exit 10
