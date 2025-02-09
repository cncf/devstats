-- Add repository groups
with repo_latest as (
  select sub.repo_id,
    sub.repo_name
  from (
    select repo_id,
      dup_repo_name as repo_name,
      row_number() over (partition by repo_id order by created_at desc, id desc) as row_num
    from
      gha_events
  ) sub
  where
    sub.row_num = 1
)
update
  gha_repos r
set
  alias = (
    select rl.repo_name
    from
      repo_latest rl
    where
      rl.repo_id = r.id
  )
where
  r.name like '%_/_%'
  and r.name not like '%/%/%'
;
update gha_repos set repo_group = alias;

update gha_repos
set repo_group = 'opencontainers/runtime-spec', alias = 'opencontainers/runtime-spec'
where name in (
  'opencontainers/runtime-spec',
  'opencontainers/specs'
);

update gha_repos
set repo_group = 'opencontainers/runc.io', alias = 'opencontainers/runc.io'
where name in (
  'opencontainers/runc.io',
  'opencontainers/runcweb'
);

update gha_repos
set repo_group = 'opencontainers/runtime-tools', alias = 'opencontainers/runtime-tools'
where name in (
  'opencontainers/ocitools',
  'opencontainers/runtime-tools'
);

update gha_repos
set repo_group = 'opencontainers/selinux', alias = 'opencontainers/selinux'
where name in (
  'opencontainers/go-selinux',
  'opencontainers/selinux'
);

insert into gha_repo_groups(id, name, alias, repo_group, org_id, org_login) select id, name, alias, coalesce(repo_group, name), org_id, org_login from gha_repos on conflict do nothing;
insert into gha_repo_groups(id, name, alias, repo_group, org_id, org_login) select id, name, alias, org_login, org_id, org_login from gha_repos where org_id is not null and org_login is not null and trim(org_login) != '' on conflict do nothing;

select
  repo_group,
  count(*) as number_of_repos
from
  gha_repo_groups
where
  repo_group is not null
group by
  repo_group
order by
  number_of_repos desc,
  repo_group asc;
