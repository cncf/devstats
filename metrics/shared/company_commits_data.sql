select
  'ccl,' || sub.repo_group as metric,
  sub.commit_date,
  0.0 as value,
  sub.company || '$$$' || sub.repo_group || '$$$' || sub.author || case sub.author_names is null when true then '' else ' (' || sub.author_names || ')' end || '$$$' || sub.commit_repo || '$$$' || sub.commit_sha || '$$$' || sub.commit_msg
from (
  select distinct af.company_name as company,
    r.repo_group as repo_group,
    c.dup_author_login as author,
    string_agg(distinct an.name, ', ') as author_names,
    c.dup_repo_name as commit_repo,
    c.sha as commit_sha,
    regexp_replace(substring(c.message for 80), '[\n\r$$$]+', ' ', 'g') as commit_msg,
    c.dup_created_at as commit_date
  from
    gha_actors_affiliations af,
    gha_repo_groups r,
    gha_commits c
  left join
    gha_actors_names an
  on
    c.author_id = an.actor_id
  where
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and c.author_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
    and c.dup_created_at >= '{{from}}'
    and c.dup_created_at < '{{to}}'
    and (lower(c.dup_author_login) {{exclude_bots}})
  group by
    af.company_name,
    c.dup_author_login,
    c.dup_repo_name,
    c.sha,
    c.message,
    c.dup_created_at,
    r.repo_group
  union select distinct af.company_name as company,
    r.repo_group as repo_group,
    c.dup_committer_login as author,
    string_agg(distinct an.name, ', ') as author_names,
    c.dup_repo_name as commit_repo,
    c.sha as commit_sha,
    regexp_replace(substring(c.message for 80), '[\n\r$$$]+', ' ', 'g') as commit_msg,
    c.dup_created_at as commit_date
  from
    gha_actors_affiliations af,
    gha_repo_groups r,
    gha_commits c
  left join
    gha_actors_names an
  on
    c.committer_id = an.actor_id
  where
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and c.committer_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
    and c.dup_created_at >= '{{from}}'
    and c.dup_created_at < '{{to}}'
    and (lower(c.dup_committer_login) {{exclude_bots}})
  group by
    af.company_name,
    c.dup_committer_login,
    c.dup_repo_name,
    c.sha,
    c.message,
    c.dup_created_at,
    r.repo_group
  union select distinct af.company_name as company,
    r.repo_group as repo_group,
    c.dup_actor_login as author,
    string_agg(distinct an.name, ', ') as author_names,
    c.dup_repo_name as commit_repo,
    c.sha as commit_sha,
    regexp_replace(substring(c.message for 80), '[\n\r$$$]+', ' ', 'g') as commit_msg,
    c.dup_created_at as commit_date
  from
    gha_actors_affiliations af,
    gha_repo_groups r,
    gha_commits c
  left join
    gha_actors_names an
  on
    c.dup_actor_id = an.actor_id
  where
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and c.dup_actor_id = af.actor_id
    and af.dt_from <= c.dup_created_at
    and af.dt_to > c.dup_created_at
    and c.dup_created_at >= '{{from}}'
    and c.dup_created_at < '{{to}}'
    and (lower(c.dup_actor_login) {{exclude_bots}})
  group by
    af.company_name,
    c.dup_actor_login,
    c.dup_repo_name,
    c.sha,
    c.message,
    c.dup_created_at,
    r.repo_group
) sub
where
  sub.repo_group is not null
;
