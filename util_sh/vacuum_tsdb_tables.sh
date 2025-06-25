#!/bin/bash
if [ -z "$1" ]
then
  echo "$0: you need to specify which DB as a 1st argument, for example 'jenkins'"
  exit 1
fi
export KENV="devstats-prod"
if [ ! -z "$TEST" ]
then
  export KENV="devstats-test"
fi

if [ -z "$N" ]
then
  export N='0'
fi

tmpfile=$(mktemp /tmp/vacuum_sql.XXXXXX.sql)
trap "rm -f $tmpfile" EXIT
kubectl exec -i -n "$KENV" "devstats-postgres-$N" -- psql -d "$1" -At -c \
"SELECT 'VACUUM FULL \"' || schemaname || '\".\"' || tablename || '\";'
 FROM pg_tables
 WHERE schemaname = 'public' AND tablename LIKE 's%';" > "$tmpfile"
cat "$tmpfile"
echo "kubectl exec -i -n \"$KENV\" \"devstats-postgres-$N\" -- psql -d \"$1\" < \"$tmpfile\""
kubectl exec -i -n "$KENV" "devstats-postgres-$N" -- psql -d "$1" < "$tmpfile"
