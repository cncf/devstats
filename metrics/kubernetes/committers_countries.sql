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
  r.id as repo_id,
  r.name as repo_name,
  r.repo_group
from
  gha_repos r
join
  trepo_groups_{{rnd}} tg
on
  tg.repo_group_name = r.repo_group
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
  c.sha,
  c.event_id,
  r.repo_group as repo_group,
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
  c.dup_created_at >= '{{from}}'
  and c.dup_created_at < '{{to}}'
;
create index on commits_base_{{rnd}}(event_id);
analyze commits_base_{{rnd}};

create temp table ecf_event_groups_{{rnd}} as
select
  ecf.event_id,
  ecf.repo_group
from
  gha_events_commits_files ecf
join (
  select distinct
    event_id
  from
    commits_base_{{rnd}}
  where
    event_id is not null
) e
on
  e.event_id = ecf.event_id
group by
  ecf.event_id,
  ecf.repo_group
;
create index on ecf_event_groups_{{rnd}}(event_id);
analyze ecf_event_groups_{{rnd}};

create temp table commits_data_{{rnd}} as
select
  coalesce(eg.repo_group, cb.repo_group) as repo_group,
  cb.sha,
  v.actor_id,
  ac.country_name
from
  commits_base_{{rnd}} cb
left join
  ecf_event_groups_{{rnd}} eg
on
  eg.event_id = cb.event_id
cross join lateral (
  values
    (cb.dup_actor_id, cb.dup_actor_login),
    (cb.author_id, cb.dup_author_login),
    (cb.committer_id, cb.dup_committer_login)
) v(actor_id, actor_login)
join
  actors_country_{{rnd}} ac
on
  ac.actor_id = v.actor_id
where
  v.actor_id is not null
  and (lower(v.actor_login) {{exclude_bots}})
;
analyze commits_data_{{rnd}};

with agg as (
  select
    'countries' as type,
    country_name,
    case when grouping(repo_group) = 1 then 'all' else repo_group end as repo_group,
    count(distinct actor_id) as rcommitters,
    count(distinct sha) as rcommits
  from
    commits_data_{{rnd}}
  group by
    grouping sets ((country_name), (country_name, repo_group))
)
select
  concat(agg.type, ';', agg.country_name, '`', agg.repo_group, ';rcommitters,rcommits') as name,
  agg.rcommitters,
  agg.rcommits
from
  agg
where
  agg.repo_group is not null
order by
  name
;

