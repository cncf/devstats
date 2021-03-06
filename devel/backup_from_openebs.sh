#!/bin/bash
export TEST_SERVER=1
. ./devel/all_dbs.sh || exit 1
found=`find /var/openebs/local -iname "*.tar.xz" -o -iname "*.dump"` || exit 2
mkdir ~/backups 1>/dev/null 2>/dev/null
for idb in $all
do
  db="$idb.tar.xz"
  hit=''
  for f in $found
  do
    fa=(${f//\// })
    f2=${fa[-1]}
    if [ "$db" = "$f2" ]
    then
      hit="$f"
      break
    fi
  done
  if [ -z "$hit" ]
  then
    echo "$db backup not found"
  else
    echo "copying $f"
    cp "$f" ~/backups/ || exit 3
  fi
  db="$idb.dump"
  hit=''
  for f in $found
  do
    fa=(${f//\// })
    f2=${fa[-1]}
    if [ "$db" = "$f2" ]
    then
      hit="$f"
      break
    fi
  done
  if [ -z "$hit" ]
  then
    echo "$db backup not found"
  else
    echo "copying $f"
    cp "$f" ~/backups/ || exit 4
  fi
done
