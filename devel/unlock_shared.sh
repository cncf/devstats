#!/bin/bash
if ( [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] )
then
  echo "$0: need database, lock name and owner arguments"
  exit 1
fi
user=gha_admin
if [ ! -z "${PG_USER}" ]
then
  user="${PG_USER}"
fi
PG_USER="${user}" ./devel/db.sh psql "$1" -c "delete from gha_locks where name = '$2' and owner = '$3'"
