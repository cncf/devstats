#!/bin/bash
if ( [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] )
then
  echo "$0: need database, lock name and owner arguments"
  exit 1
fi
if [ -z "$PG_PASS" ]
then
  echo "$0: You need to set PG_PASS environment variable to run this script"
  exit 2
fi
attempts=720
if [ ! -z "$4" ]
then
  attempts=$4
fi
user=gha_admin
if [ ! -z "${PG_USER}" ]
then
  user="${PG_USER}"
fi
i=0
while true
do
  PG_USER="${user}" ./devel/db.sh psql "$1" -c "insert into gha_locks(name, owner) values('$2', '$3') on conflict do nothing"
  got=`PG_USER="${user}" ./devel/db.sh psql "$1" -tAc "select owner from gha_locks where name = '$2'"`
  if [ "$got" = "$3" ]
  then
    echo "$1: acquired '$2' lock ($3)"
    exit 0
  fi
  i=$((i+1))
  if [ "$i" -ge "$attempts" ]
  then
    echo "$1: could not acquire '$2' lock after $attempts attempts, current owner: '$got'"
    exit 3
  fi
  sleep 10
done
