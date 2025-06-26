#!/bin/bash
export KENV="prod"
if [ ! -z "$TEST" ]
then
  export KENV="test"
fi
for db in $(cat "devel/all_${KENV}_dbs.txt")
do
  echo "DB: $db"
  ./util_sh/recreate_tsdb_tables.sh "$db"
done
