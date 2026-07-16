#!/bin/bash
# SKIP_AFFS_LOCK=1 (skip the affs_lock flag serializing shared-DB affiliation writers)
if ( [ -z "$GHA2DB_PROJECT" ] || [ -z "$PG_DB" ] || [ -z "$PG_PASS" ] )
then
  echo "$0: you need to set GHA2DB_PROJECT, PG_DB, PG_PASS env variables to use this script"
  exit 1
fi
if [ -z "$GHA2DB_AFFILIATIONS_DB" ]
then
  ./shared/import_affs.sh
  exit $?
fi
adb="${GHA2DB_AFFILIATIONS_DB}"
affsLockDB=devstats
lockOwner="${HOSTNAME}-$$-${RANDOM}"
lock=''
function clear_affs_lock {
  if [ ! -z "$lock" ]
  then
    ./devel/unlock_shared.sh "$affsLockDB" affs_lock "$lockOwner"
    lock=''
  fi
}
function finish {
  clear_affs_lock
  sync_unlock.sh
}
if [ -z "$TRAP" ]
then
  sync_lock.sh || exit -1
  trap finish EXIT
  export TRAP=1
else
  trap clear_affs_lock EXIT
fi
if ( [ -z "$SKIP_AFFS_LOCK" ] || [ "$SKIP_AFFS_LOCK" = "0" ] || [ "$SKIP_AFFS_LOCK" = "false" ] )
then
  ./devel/lock_shared.sh "$affsLockDB" affs_lock "$lockOwner" || exit 2
  lock=1
fi
wget https://github.com/cncf/devstats/raw/master/github_users.json -O github_users.json || exit 4
wget https://github.com/cncf/devstats/raw/master/companies.yaml -O companies.yaml || exit 5
PG_DB="$adb" GHA2DB_LOCAL=1 GHA2DB_CHECK_IMPORTED_SHA='' import_affs || exit 6
PG_DB="$adb" GHA2DB_LOCAL=1 runq util_sql/update_country_names.sql || exit 7
PG_DB="$adb" GHA2DB_LOCAL=1 runq util_sql/shared_maps.sql || exit 8
GHA2DB_TAGS_YAML=metrics/$GHA2DB_PROJECT/tags_affs.yaml GHA2DB_LOCAL=1 tags || exit 9
GHA2DB_COLUMNS_YAML=metrics/$GHA2DB_PROJECT/columns_affs.yaml GHA2DB_LOCAL=1 columns || exit 10
