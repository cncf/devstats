create temp table trepo_groups_{{rnd}} as
select distinct
  repo_group_name
from
  trepo_groups
;
create index on trepo_groups_{{rnd}}(repo_group_name);
analyze trepo_groups_{{rnd}};

create temp table repo_groups_{{rnd}} as
select
  id as repo_id,
  name as repo_name,
  repo_group
from
  gha_repo_groups
where
  repo_group is not null
  and repo_group in (select repo_group_name from trepo_groups_{{rnd}})
;
create index on repo_groups_{{rnd}}(repo_id, repo_name);
analyze repo_groups_{{rnd}};

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
  rg.repo_group,
  c.sha,
  c.dup_actor_id,
  c.dup_actor_login,
  c.author_id,
  c.dup_author_login,
  c.committer_id,
  c.dup_committer_login
from
  repo_groups_{{rnd}} rg
join
  gha_commits c
on
  c.dup_repo_id = rg.repo_id
  and c.dup_repo_name = rg.repo_name
where
  c.dup_created_at < '{{to}}'
;
analyze commits_base_{{rnd}};

with agg as (
  select
    'countriescum' as type,
    ac.country_name as country_name,
    case when grouping(cb.repo_group) = 1 then 'all' else cb.repo_group end as repo_group,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(v.actor_id)))) as rcommitters,
    round(hll_cardinality(hll_add_agg(hll_hash_text(cb.sha)))) as rcommits
  from
    commits_base_{{rnd}} cb
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
  group by
    grouping sets ((ac.country_name), (ac.country_name, cb.repo_group))
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

