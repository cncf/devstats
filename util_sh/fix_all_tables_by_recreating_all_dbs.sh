#!/bin/bash
if [ -z "${STAGE}" ]
then
  export STAGE="test"
fi
for db in $(cat "devel/all_${STAGE}_dbs.txt")
do
  echo "DB: ${db}"
  ./util_sh/fix_all_tables_by_recreating.sh "${db}"
done
