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

tmpfile=$(mktemp /tmp/recreate_sql.XXXXXX.sql)
trap "rm -f \"$tmpfile\"" EXIT
> "$tmpfile"
for t in $(kubectl exec -in "$KENV" "devstats-postgres-$N" -- psql -d "$1" -At -c "select tablename from pg_tables where schemaname = 'public' AND tablename LIKE 's%'")
do
    # echo "$1:$t"
    echo "create table \"${t}_tmp\" (like \"$t\" including all);" >> "$tmpfile"
    echo "insert into \"${t}_tmp\" select * from \"$t\";" >> "$tmpfile"
    echo "drop table \"$t\";" >> "$tmpfile"
    echo "alter table \"${t}_tmp\" rename to \"$t\";" >> "$tmpfile"
    echo "alter table \"$t\" owner to gha_admin;" >> "$tmpfile"
    echo "grant select on \"$t\" to \"devstats_team\";" >> "$tmpfile"
done

# cat "$tmpfile"
echo "kubectl exec -i -n \"$KENV\" \"devstats-postgres-$N\" -- psql -d \"$1\" < \"$tmpfile\""
kubectl exec -i -n "$KENV" "devstats-postgres-$N" -- psql -d "$1" < "$tmpfile"
