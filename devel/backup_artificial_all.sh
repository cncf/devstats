#!/bin/bash
. ./devel/all_dbs.sh || exit 2
for db in $all
do
  echo "DB: $db"
  ./cron/backup_artificial.sh "$db" || exit 1
done
