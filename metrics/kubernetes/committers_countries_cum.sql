create temp table trepo_groups_{{rnd}} as
select distinct
  repo_group_name
from
  trepo_groups
;
create index on trepo_groups_{{rnd}}(repo_group_name);
analyze trepo_groups_{{rnd}};

create temp table repos_{{rnd}} as
select
  id as repo_id,
  name as repo_name,
  repo_group
from
  gha_repos
where
  repo_group in (select repo_group_name from trepo_groups_{{rnd}})
;
create index on repos_{{rnd}}(repo_id, repo_name);
analyze repos_{{rnd}};

create temp table actors_country_{{rnd}} as
select
  id as actor_id,
  country_name
from
  gha_actors
where
  country_name is not null
  and country_name != ''
  and (lower(login) {{exclude_bots}})
;
create index on actors_country_{{rnd}}(actor_id);
analyze actors_country_{{rnd}};

create temp table commits_base_{{rnd}} as
select
  r.repo_group as repo_group_base,
  c.sha,
  c.event_id,
  c.dup_actor_id,
  c.dup_actor_login,
  c.author_id,
  c.dup_author_login,
  c.committer_id,
  c.dup_committer_login
from
  gha_commits c
join
  repos_{{rnd}} r
on
  c.dup_repo_id = r.repo_id
  and c.dup_repo_name = r.repo_name
where
  c.dup_created_at < '{{to}}'
;
create index on commits_base_{{rnd}}(event_id);
analyze commits_base_{{rnd}};

create temp table commit_event_ids_{{rnd}} as
select distinct
  event_id
from
  commits_base_{{rnd}}
where
  event_id is not null
;
create index on commit_event_ids_{{rnd}}(event_id);
analyze commit_event_ids_{{rnd}};

create temp table ecf_event_groups_{{rnd}} as
select distinct
  ecf.event_id,
  ecf.repo_group
from
  gha_events_commits_files ecf
join
  commit_event_ids_{{rnd}} eids
on
  eids.event_id = ecf.event_id
where
  ecf.repo_group is not null
;
create index on ecf_event_groups_{{rnd}}(event_id);
analyze ecf_event_groups_{{rnd}};

with commits_expanded as (
  select
    coalesce(eg.repo_group, cb.repo_group_base) as repo_group,
    cb.sha,
    v.actor_id
  from
    commits_base_{{rnd}} cb
  left join
    ecf_event_groups_{{rnd}} eg
  on
    eg.event_id = cb.event_id
  cross join lateral (
    select distinct
      actor_id
    from (
      values
        (cb.dup_actor_id, cb.dup_actor_login),
        (cb.author_id, cb.dup_author_login),
        (cb.committer_id, cb.dup_committer_login)
    ) x(actor_id, actor_login)
    where
      actor_id is not null
      and (lower(actor_login) {{exclude_bots}})
  ) v
), agg as (
  select
    'countriescum' as type,
    ac.country_name,
    case when grouping(ce.repo_group) = 1 then 'all' else ce.repo_group end as repo_group,
    count(distinct ce.actor_id) as rcommitters,
    count(distinct ce.sha) as rcommits
  from
    commits_expanded ce
  join
    actors_country_{{rnd}} ac
  on
    ac.actor_id = ce.actor_id
  group by
    grouping sets ((ac.country_name), (ac.country_name, ce.repo_group))
)
select
  concat(type, ';', country_name, '`', repo_group, ';rcommitters,rcommits') as name,
  rcommitters,
  rcommits
from
  agg
where
  repo_group is not null
order by
  name
;

