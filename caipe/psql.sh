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
GHA2DB_PROJECT=caipe PG_DB=caipe GHA2DB_LOCAL=1 structure 2>>errors.txt | tee -a run.log || exit 1
./devel/db.sh psql caipe -c "create extension if not exists pgcrypto" || exit 1
./devel/db.sh psql caipe -c "create extension if not exists hll" || exit 1
./shared/setup_shared_fdw.sh caipe || exit 1
./devel/ro_user_grants.sh caipe || exit 2
GHA2DB_PROJECT=caipe PG_DB=caipe GHA2DB_LOCAL=1 gha2db 2025-05-26 0 today now 'caipe-io,cnoe-io/caipe-cli,cnoe-io/agent-chat-cli,cnoe-io/ai-platform-engineering' 2>>errors.txt | tee -a run.log || exit 3
GHA2DB_PROJECT=caipe PG_DB=caipe GHA2DB_LOCAL=1 GHA2DB_MGETC=y GHA2DB_SKIPTABLE=1 GHA2DB_INDEX=1 structure 2>>errors.txt | tee -a run.log || exit 5
GHA2DB_PROJECT=caipe PG_DB=caipe ./shared/setup_repo_groups.sh 2>>errors.txt | tee -a run.log || exit 6
GHA2DB_PROJECT=caipe PG_DB=caipe ./shared/setup_scripts.sh 2>>errors.txt | tee -a run.log || exit 7
GHA2DB_PROJECT=caipe PG_DB=caipe ./shared/get_repos.sh 2>>errors.txt | tee -a run.log || exit 8
GHA2DB_PROJECT=caipe PG_DB=caipe ./shared/proj_affs_bootstrap.sh 2>>errors.txt | tee -a run.log || exit 9
GHA2DB_PROJECT=caipe PG_DB=caipe GHA2DB_LOCAL=1 vars || exit 10
