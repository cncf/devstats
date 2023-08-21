with commits_data as (
  select r.repo_group as repo_group,
    c.sha,
    aa.company_name as company
  from
    gha_repos r,
    gha_commits c,
    gha_actors_affiliations aa
  where
    aa.actor_id = c.dup_actor_id
    and aa.dt_from <= c.dup_created_at
    and aa.dt_to > c.dup_created_at
    and c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and {{period:c.dup_created_at}}
    and (lower(c.dup_actor_login) {{exclude_bots}})
    and aa.company_name in (select companies_name from tcompanies)
  union select r.repo_group as repo_group,
    c.sha,
    aa.company_name as company
  from
    gha_repos r,
    gha_commits c,
    gha_actors_affiliations aa
  where
    aa.actor_id = c.author_id
    and aa.dt_from <= c.dup_created_at
    and aa.dt_to > c.dup_created_at
    and c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and c.author_id is not null
    and {{period:c.dup_created_at}}
    and (lower(c.dup_author_login) {{exclude_bots}})
    and aa.company_name in (select companies_name from tcompanies)
  union select r.repo_group as repo_group,
    c.sha,
    aa.company_name as company
  from
    gha_repos r,
    gha_commits c,
    gha_actors_affiliations aa
  where
    aa.actor_id = c.committer_id
    and aa.dt_from <= c.dup_created_at
    and aa.dt_to > c.dup_created_at
    and c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and c.committer_id is not null
    and {{period:c.dup_created_at}}
    and (lower(c.dup_committer_login) {{exclude_bots}})
    and aa.company_name in (select companies_name from tcompanies)
  union select r.repo_group as repo_group,
    cr.sha,
    aa.company_name as company
  from
    gha_repos r,
    gha_commits_roles cr,
    gha_actors_affiliations aa
  where
    aa.actor_id = cr.actor_id
    and aa.dt_from <= cr.dup_created_at
    and aa.dt_to > cr.dup_created_at
    and cr.dup_repo_id = r.id
    and cr.dup_repo_name = r.name
    and cr.actor_id is not null
    and cr.actor_id != 0
    and cr.role = 'Co-authored-by'
    and {{period:cr.dup_created_at}}
    and (lower(cr.actor_login) {{exclude_bots}})
    and aa.company_name in (select companies_name from tcompanies)
), data as (
  select aa.company_name as company,
    r.repo_group,
    'contributions' as metric,
    e.id
  from
    gha_events e,
    gha_repos r,
    gha_actors_affiliations aa
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and e.actor_id = aa.actor_id
    and aa.dt_from <= e.created_at
    and aa.dt_to > e.created_at
    and e.type in (
      'IssuesEvent', 'PullRequestEvent', 'PushEvent',
      'PullRequestReviewCommentEvent', 'IssueCommentEvent',
      'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
    )
    and {{period:e.created_at}}
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and aa.company_name in (select companies_name from tcompanies)
  union select aa.company_name as company,
    r.repo_group,
    case e.type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    e.id
  from
    gha_events e,
    gha_repos r,
    gha_actors_affiliations aa
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and aa.actor_id = e.actor_id
    and aa.dt_from <= e.created_at
    and aa.dt_to > e.created_at
    and e.type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and {{period:e.created_at}}
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and aa.company_name in (select companies_name from tcompanies)
  union select aa.company_name as company,
    r.repo_group,
    'active_repos' as metric,
    e.repo_id as id
  from
    gha_events e,
    gha_repos r,
    gha_actors_affiliations aa
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and aa.actor_id = e.actor_id
    and aa.dt_from <= e.created_at
    and aa.dt_to > e.created_at
    and {{period:e.created_at}}
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and aa.company_name in (select companies_name from tcompanies)
  union select aa.company_name as company,
    r.repo_group,
    'comments' as metric,
    c.id
  from
    gha_repos r,
    gha_comments c,
    gha_actors_affiliations aa
  where
    r.name = c.dup_repo_name
    and r.id = c.dup_repo_id
    and aa.actor_id = c.user_id
    and aa.dt_from <= c.created_at
    and aa.dt_to > c.created_at
    and {{period:c.created_at}}
    and (lower(c.dup_user_login) {{exclude_bots}})
    and aa.company_name in (select companies_name from tcompanies)
  union select aa.company_name as company,
    r.repo_group,
    'issues' as metric,
    i.id
  from
    gha_repos r,
    gha_issues i,
    gha_actors_affiliations aa
  where
    r.name = i.dup_repo_name
    and r.id = i.dup_repo_id
    and aa.actor_id = i.user_id
    and aa.dt_from <= i.created_at
    and aa.dt_to > i.created_at
    and {{period:i.created_at}}
    and i.is_pull_request = false
    and (lower(i.dup_user_login) {{exclude_bots}})
    and aa.company_name in (select companies_name from tcompanies)
  union select aa.company_name as company,
    r.repo_group,
    'prs' as metric,
    i.id
  from
    gha_repos r,
    gha_issues i,
    gha_actors_affiliations aa
  where
    r.name = i.dup_repo_name
    and r.id = i.dup_repo_id
    and aa.actor_id = i.user_id
    and aa.dt_from <= i.created_at
    and aa.dt_to > i.created_at
    and {{period:i.created_at}}
    and i.is_pull_request = true
    and (lower(i.dup_user_login) {{exclude_bots}})
    and aa.company_name in (select companies_name from tcompanies)
  union select aa.company_name as company,
    r.repo_group,
    'merged_prs' as metric,
    i.id
  from
    gha_repos r,
    gha_pull_requests i,
    gha_actors_affiliations aa
  where
    r.name = i.dup_repo_name
    and r.id = i.dup_repo_id
    and aa.actor_id = i.user_id
    and i.merged_at is not null
    and aa.dt_from <= i.merged_at
    and aa.dt_to > i.merged_at
    and {{period:i.merged_at}}
    and (lower(i.dup_user_login) {{exclude_bots}})
    and aa.company_name in (select companies_name from tcompanies)
  union select aa.company_name as company,
    r.repo_group,
    'events' as metric,
    e.id
  from
    gha_repos r,
    gha_events e,
    gha_actors_affiliations aa
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and aa.actor_id = e.actor_id
    and aa.dt_from <= e.created_at
    and aa.dt_to > e.created_at
    and {{period:e.created_at}}
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and aa.company_name in (select companies_name from tcompanies)
)
select
  'hcom_contrib,' || company || '_' || metric as company_contrib,
  repo_group,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as contribs
from
  data
group by
  repo_group,
  company,
  metric
union select 'hcom_contrib,' || company || '_' || metric as company_contrib,
  'All',
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id))))
from
  data
group by
  company,
  metric
union select 'hcom_contrib,' || company || '_commits' as company_contrib,
  repo_group,
  round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) as contribs
from
  commits_data
group by
  repo_group,
  company
union select 'hcom_contrib,' || company || '_commits' as company_contrib,
  'All',
  round(hll_cardinality(hll_add_agg(hll_hash_text(sha))))
from
  commits_data
group by
  company
;
