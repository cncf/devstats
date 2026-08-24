create temp table pcc_commits_{{rnd}} as
select r.repo_group as repo_group,
  c.sha,
  c.dup_actor_id as actor_id,
  c.author_id,
  c.committer_id,
  (lower(c.dup_actor_login) {{exclude_bots}}) as f_actor,
  (lower(c.dup_author_login) {{exclude_bots}}) as f_author,
  (lower(c.dup_committer_login) {{exclude_bots}}) as f_committer
from
  gha_repo_groups r,
  gha_commits c
where
  c.dup_repo_id = r.id
  and c.dup_repo_name = r.name
  and c.dup_created_at >= '{{from}}'
  and c.dup_created_at < '{{to}}'
  and (
    (lower(c.dup_actor_login) {{exclude_bots}})
    or (c.author_id is not null and (lower(c.dup_author_login) {{exclude_bots}}))
    or (c.committer_id is not null and (lower(c.dup_committer_login) {{exclude_bots}}))
  );
analyze pcc_commits_{{rnd}};
with commits_data as (
  select repo_group,
    sha,
    actor_id
  from
    pcc_commits_{{rnd}}
  where
    f_actor
  union select repo_group,
    sha,
    author_id as actor_id
  from
    pcc_commits_{{rnd}}
  where
    author_id is not null
    and f_author
  union select repo_group,
    sha,
    committer_id as actor_id
  from
    pcc_commits_{{rnd}}
  where
    committer_id is not null
    and f_committer
), data as (
  select 'prjcntr' as type,
    a.country_name,
    c.repo_group,
    hll_add_agg(hll_hash_bigint(c.actor_id)) as rcommitters,
    hll_add_agg(hll_hash_text(c.sha)) as rcommits
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
)
select
  concat(inn.type, ';', inn.repo_group, '`', inn.country_name, ';rcommitters,rcommits') as name,
  inn.rcommitters,
  inn.rcommits
from
  data inn
where
  inn.repo_group is not null 
order by
  name
;
drop table pcc_commits_{{rnd}};
