with companies as (
  select
    companies_name as company
  from
    tcompanies
), aff as (
  select
    aa.actor_id,
    aa.company_name,
    aa.dt_from,
    aa.dt_to
  from
    gha_actors_affiliations aa
  join
    companies c
  on
    c.company = aa.company_name
), commits_data as (
  select
    rg.repo_group,
    c.sha,
    a.company_name as company
  from
    gha_commits c
  join
    gha_repo_groups rg
  on
    rg.id = c.dup_repo_id
    and rg.name = c.dup_repo_name
  join lateral (
    values
      (c.dup_actor_id, lower(c.dup_actor_login)),
      (c.author_id, lower(c.dup_author_login)),
      (c.committer_id, lower(c.dup_committer_login))
  ) as u(actor_id, actor_login)
  on
    u.actor_id is not null
  join
    aff a
  on
    a.actor_id = u.actor_id
    and a.dt_from <= c.dup_created_at
    and a.dt_to > c.dup_created_at
  where
    {{period:c.dup_created_at}}
    and (u.actor_login {{exclude_bots}})
  union all
  select
    rg.repo_group,
    cr.sha,
    a.company_name as company
  from
    gha_commits_roles cr
  join
    gha_repo_groups rg
  on
    rg.id = cr.dup_repo_id
    and rg.name = cr.dup_repo_name
  join
    aff a
  on
    a.actor_id = cr.actor_id
    and a.dt_from <= cr.dup_created_at
    and a.dt_to > cr.dup_created_at
  where
    cr.role = 'Co-authored-by'
    and cr.actor_id is not null
    and cr.actor_id != 0
    and {{period:cr.dup_created_at}}
    and (lower(cr.actor_login) {{exclude_bots}})
), events_base as (
  select
    a.company_name as company,
    rg.repo_group,
    e.id,
    e.repo_id,
    e.type
  from
    gha_events e
  join
    gha_repo_groups rg
  on
    rg.name = e.dup_repo_name
    and rg.id = e.repo_id
  join
    aff a
  on
    a.actor_id = e.actor_id
    and a.dt_from <= e.created_at
    and a.dt_to > e.created_at
  where
    {{period:e.created_at}}
    and (lower(e.dup_actor_login) {{exclude_bots}})
), comments_base as (
  select
    a.company_name as company,
    rg.repo_group,
    c.id
  from
    gha_comments c
  join
    gha_repo_groups rg
  on
    rg.name = c.dup_repo_name
    and rg.id = c.dup_repo_id
  join
    aff a
  on
    a.actor_id = c.user_id
    and a.dt_from <= c.created_at
    and a.dt_to > c.created_at
  where
    {{period:c.created_at}}
    and (lower(c.dup_user_login) {{exclude_bots}})
), issues_base as (
  select
    a.company_name as company,
    rg.repo_group,
    i.id
  from
    gha_issues i
  join
    gha_repo_groups rg
  on
    rg.name = i.dup_repo_name
    and rg.id = i.dup_repo_id
  join
    aff a
  on
    a.actor_id = i.user_id
    and a.dt_from <= i.created_at
    and a.dt_to > i.created_at
  where
    {{period:i.created_at}}
    and i.is_pull_request = false
    and (lower(i.dup_user_login) {{exclude_bots}})
), prs_base as (
  select
    a.company_name as company,
    rg.repo_group,
    i.id
  from
    gha_issues i
  join
    gha_repo_groups rg
  on
    rg.name = i.dup_repo_name
    and rg.id = i.dup_repo_id
  join
    aff a
  on
    a.actor_id = i.user_id
    and a.dt_from <= i.created_at
    and a.dt_to > i.created_at
  where
    {{period:i.created_at}}
    and i.is_pull_request = true
    and (lower(i.dup_user_login) {{exclude_bots}})
), merged_prs_base as (
  select
    a.company_name as company,
    rg.repo_group,
    pr.id
  from
    gha_pull_requests pr
  join
    gha_repo_groups rg
  on
    rg.name = pr.dup_repo_name
    and rg.id = pr.dup_repo_id
  join
    aff a
  on
    a.actor_id = pr.user_id
    and a.dt_from <= pr.merged_at
    and a.dt_to > pr.merged_at
  where
    pr.merged_at is not null
    and {{period:pr.merged_at}}
    and (lower(pr.dup_user_login) {{exclude_bots}})
), data as (
  select
    company,
    repo_group,
    'events'::text as metric,
    id::bigint as id
  from
    events_base
  union all
  select
    company,
    repo_group,
    'contributions'::text as metric,
    id::bigint as id
  from
    events_base
  where
    type in (
      'IssuesEvent', 'PullRequestEvent', 'PushEvent',
      'PullRequestReviewCommentEvent', 'IssueCommentEvent',
      'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
    )
  union all
  select
    company,
    repo_group,
    case type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    id::bigint as id
  from
    events_base
  where
    type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
  union all
  select
    company,
    repo_group,
    'active_repos'::text as metric,
    repo_id::bigint as id
  from
    events_base
  union all
  select
    company,
    repo_group,
    'comments'::text as metric,
    id::bigint as id
  from
    comments_base
  union all
  select
    company,
    repo_group,
    'issues'::text as metric,
    id::bigint as id
  from
    issues_base
  union all
  select
    company,
    repo_group,
    'prs'::text as metric,
    id::bigint as id
  from
    prs_base
  union all
  select
    company,
    repo_group,
    'merged_prs'::text as metric,
    id::bigint as id
  from
    merged_prs_base
), data_agg as (
  select
    'hcom_contrib,' || company || '_' || metric as company_contrib,
    case when grouping(repo_group) = 1 then 'All' else repo_group end as repo_group,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as contribs
  from
    data
  group by
    grouping sets ((company, metric, repo_group), (company, metric))
), commits_agg as (
  select
    'hcom_contrib,' || company || '_commits' as company_contrib,
    case when grouping(repo_group) = 1 then 'All' else repo_group end as repo_group,
    round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) as contribs
  from
    commits_data
  group by
    grouping sets ((company, repo_group), (company))
)
select
  company_contrib,
  repo_group,
  contribs
from
  data_agg
union all
select
  company_contrib,
  repo_group,
  contribs
from
  commits_agg
order by
  company_contrib asc,
  repo_group asc
;

