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
GHA2DB_PROJECT=kubeburner PG_DB=kubeburner GHA2DB_LOCAL=1 structure 2>>errors.txt | tee -a run.log || exit 1
./devel/db.sh psql kubeburner -c "create extension if not exists pgcrypto" || exit 1
./devel/db.sh psql kubeburner -c "create extension if not exists hll" || exit 1
./devel/ro_user_grants.sh kubeburner || exit 2
GHA2DB_PROJECT=kubeburner PG_DB=kubeburner GHA2DB_LOCAL=1 gha2db 2020-09-02 0 today now 'kube-burner,cloud-bulldozer/kube-burner,cloud-bulldozer/rosa-burner' 2>>errors.txt | tee -a run.log || exit 3
GHA2DB_PROJECT=kubeburner PG_DB=kubeburner GHA2DB_LOCAL=1 GHA2DB_MGETC=y GHA2DB_SKIPTABLE=1 GHA2DB_INDEX=1 structure 2>>errors.txt | tee -a run.log || exit 5
GHA2DB_PROJECT=kubeburner PG_DB=kubeburner ./shared/setup_repo_groups.sh 2>>errors.txt | tee -a run.log || exit 6
GHA2DB_PROJECT=kubeburner PG_DB=kubeburner ./shared/setup_scripts.sh 2>>errors.txt | tee -a run.log || exit 7
GHA2DB_PROJECT=kubeburner PG_DB=kubeburner ./shared/get_repos.sh 2>>errors.txt | tee -a run.log || exit 8
GHA2DB_PROJECT=kubeburner PG_DB=kubeburner ./shared/import_affs.sh 2>>errors.txt | tee -a run.log || exit 9
GHA2DB_PROJECT=kubeburner PG_DB=kubeburner GHA2DB_LOCAL=1 vars || exit 10
