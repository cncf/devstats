#!/bin/bash
if ( [ -z "${1}" ] || [ -z "${2}" ] )
then
  echo "${0}: required two parameters: db-name table-name"
  exit 1
fi
if [ -z "${STAGE}" ]
then
  STAGE=test
fi
if [ -z "${N}" ]
then
  N=0
fi
db="$1"
tab="$2"
kubectl exec -n "devstats-${STAGE}" -it "devstats-postgres-${N}" -- psql "$db" -tAc "
set local client_min_messages = warning;
begin;
lock table \"${tab}\" in access exclusive mode;
drop table if exists \"${tab}_tmp\";
create table \"${tab}_tmp\" (like \"${tab}\" including all);
insert into \"${tab}_tmp\" select * from \"${tab}\";
drop table if exists \"${tab}_old\";
alter table \"${tab}\" rename to \"${tab}_old\";
alter table \"${tab}_tmp\" rename to \"${tab}\";
drop table \"${tab}_old\";
alter table \"${tab}\" owner to \"gha_admin\";
grant select on \"${tab}\" to \"devstats_team\";
grant select on \"${tab}\" to \"ro_user\";
commit;
select count(*) from \"${tab}\";
"
