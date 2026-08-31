create temp table repo_groups_{{rnd}} as
select
  id as repo_id,
  name as repo_name,
  repo_group
from
  gha_repo_groups
where
  repo_group is not null
  and repo_group in (select repo_group_name from trepo_groups)
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

create temp table commits_data_{{rnd}} as
select
  rg.repo_group,
  ac.country_name,
  hll_hash_bigint(v.actor_id) as h_actor,
  hll_hash_text(c.sha) as h_sha
from
  gha_commits c
join
  repo_groups_{{rnd}} rg
on
  c.dup_repo_id = rg.repo_id
  and c.dup_repo_name = rg.repo_name
cross join lateral (
  values
    (c.dup_actor_id, c.dup_actor_login),
    (c.author_id, c.dup_author_login),
    (c.committer_id, c.dup_committer_login)
) v(actor_id, actor_login)
join
  actors_country_{{rnd}} ac
on
  ac.actor_id = v.actor_id
where
  c.dup_created_at >= '{{from}}'
  and c.dup_created_at < '{{to}}'
  and v.actor_id is not null
  and (lower(v.actor_login) {{exclude_bots}})
;
analyze commits_data_{{rnd}};

with inn as (
  select
    'countries' as type,
    country_name,
    case when grouping(repo_group) = 1 then 'all' else repo_group end as repo_group,
    round(hll_cardinality(hll_add_agg(h_actor))) as rcommitters,
    round(hll_cardinality(hll_add_agg(h_sha))) as rcommits
  from
    commits_data_{{rnd}}
  group by
    grouping sets ((country_name), (country_name, repo_group))
)
select
  concat(inn.type, ';', inn.country_name, '`', inn.repo_group, ';rcommitters,rcommits') as name,
  inn.rcommitters,
  inn.rcommits
from
  inn
where
  inn.repo_group is not null
order by
  name
;

