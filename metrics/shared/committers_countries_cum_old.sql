with commits_data as (
  select r.repo_group as repo_group,
    c.sha,
    c.dup_actor_id as actor_id
  from
    gha_repo_groups r,
    gha_commits c
  where
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and c.dup_created_at < '{{to}}'
    and (lower(c.dup_actor_login) {{exclude_bots}})
    and r.repo_group in (select repo_group_name from trepo_groups)
  union select r.repo_group as repo_group,
    c.sha,
    c.author_id as actor_id
  from
    gha_repo_groups r,
    gha_commits c
  where
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and c.author_id is not null
    and c.dup_created_at < '{{to}}'
    and (lower(c.dup_author_login) {{exclude_bots}})
    and r.repo_group in (select repo_group_name from trepo_groups)
  union select r.repo_group as repo_group,
    c.sha,
    c.committer_id as actor_id
  from
    gha_repo_groups r,
    gha_commits c
  where
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and c.committer_id is not null
    and c.dup_created_at < '{{to}}'
    and (lower(c.dup_committer_login) {{exclude_bots}})
    and r.repo_group in (select repo_group_name from trepo_groups)
)
select
  concat(inn.type, ';', inn.country_name, '`', inn.repo_group, ';rcommitters,rcommits') as name,
  inn.rcommitters,
  inn.rcommits
from (
  select 'countriescum' as type,
    a.country_name,
    'all' as repo_group,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(c.actor_id)))) as rcommitters,
    round(hll_cardinality(hll_add_agg(hll_hash_text(c.sha)))) as rcommits
  from
    commits_data c,
    gha_actors a
  where
    (lower(a.login) {{exclude_bots}})
    and a.id = c.actor_id
    and a.country_name is not null
    and a.country_name != ''
  group by
    a.country_name
  union select 'countriescum' as type,
    a.country_name,
    c.repo_group,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(c.actor_id)))) as rcommitters,
    round(hll_cardinality(hll_add_agg(hll_hash_text(c.sha)))) as rcommits
  from
    commits_data c,
    gha_actors a
  where
    (lower(a.login) {{exclude_bots}})
    and a.id = c.actor_id
    and a.country_name is not null
    and a.country_name != ''
  group by
    a.country_name,
    c.repo_group
) inn
where
  inn.repo_group is not null 
order by
  name
;
