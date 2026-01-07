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
    and {{period:c.dup_created_at}}
    and (lower(c.dup_actor_login) {{exclude_bots}})
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
    and {{period:c.dup_created_at}}
    and (lower(c.dup_author_login) {{exclude_bots}})
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
    and {{period:c.dup_created_at}}
    and (lower(c.dup_committer_login) {{exclude_bots}})
)
select
  'pstat,All' as repo_group,
  'Projects/Repository groups' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_text(repo_group)))) as value
from
  gha_repo_groups
where
  repo_group is not null
union select
  'pstat,All' as repo_group,
  'Countries' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_text(sub.country_id)))) as value
from (
  select
    a.country_id
  from
    gha_events e,
    gha_actors a
  where
    {{period:e.created_at}}
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.actor_id = a.id
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  union select
    a.country_id
  from
    gha_actors a,
    gha_commits c
  where
    {{period:c.dup_created_at}}
    and (lower(c.dup_author_login) {{exclude_bots}})
    and c.author_id = a.id
  union select
    a.country_id
  from
    gha_actors a,
    gha_commits c
  where
    {{period:c.dup_created_at}}
    and (lower(c.dup_committer_login) {{exclude_bots}})
    and c.committer_id = a.id
) sub
union select
  'pstat,' || sub.repo_group as repo_group,
  'Countries' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_text(sub.country_id)))) as value
from (
  select
    a.country_id,
    r.repo_group
  from
    gha_events e,
    gha_actors a,
    gha_repo_groups r
  where
    {{period:e.created_at}}
    and e.repo_id = r.id
    and e.dup_repo_name = r.name
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.actor_id = a.id
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  union select
    a.country_id,
    r.repo_group
  from
    gha_actors a,
    gha_commits c,
    gha_repo_groups r
  where
    {{period:c.dup_created_at}}
    and c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and (lower(c.dup_author_login) {{exclude_bots}})
    and c.author_id = a.id
  union select
    a.country_id,
    r.repo_group
  from
    gha_actors a,
    gha_commits c,
    gha_repo_groups r
  where
    {{period:c.dup_created_at}}
    and c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and (lower(c.dup_committer_login) {{exclude_bots}})
    and c.committer_id = a.id
) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
union select
  sub.repo_group,
  'Contributors' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_text(sub.actor)))) as value
from (
  select 'pstat,' || r.repo_group as repo_group,
    e.dup_actor_login as actor
  from
    gha_repo_groups r,
    gha_events e
  where
    {{period:e.created_at}}
    and e.repo_id = r.id
    and e.dup_repo_name = r.name
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
union select 'pstat,All' as repo_group,
  'Contributors' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_text(dup_actor_login)))) as value
from
  gha_events
where
  {{period:created_at}}
  and (lower(dup_actor_login) {{exclude_bots}})
  and type in (
    'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
    'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
  )
union select
  sub.repo_group,
  'Contributions' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(sub.id)))) as value
from (
  select 'pstat,' || r.repo_group as repo_group,
    e.id
  from
    gha_repo_groups r,
    gha_events e
  where
    {{period:e.created_at}}
    and e.repo_id = r.id
    and e.dup_repo_name = r.name
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
union select 'pstat,All' as repo_group,
  'Contributions' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as value
from
  gha_events
where
  {{period:created_at}}
  and (lower(dup_actor_login) {{exclude_bots}})
  and type in (
    'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
    'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
  )
union select
  sub.repo_group,
  'Pushes' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(sub.id)))) as value
from (
  select 'pstat,' || r.repo_group as repo_group,
    e.id
  from
    gha_repo_groups r,
    gha_events e
  where
    {{period:e.created_at}}
    and e.repo_id = r.id
    and e.dup_repo_name = r.name
    and (lower(e.dup_actor_login) {{exclude_bots}})
    and e.type = 'PushEvent'
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
union select 'pstat,All' as repo_group,
  'Pushes' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as value
from
  gha_events
where
  {{period:created_at}}
  and (lower(dup_actor_login) {{exclude_bots}})
  and type = 'PushEvent'
union select 'pstat,' || c.repo_group as repo_group,
  'Commits' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_text(c.sha)))) as value
from
  commits_data c
where
  c.repo_group is not null
group by
  c.repo_group
union select 'pstat,All' as repo_group,
  'Commits' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_text(c.sha)))) as value
from
  commits_data c
union select 'pstat,' || c.repo_group as repo_group,
  'Code committers' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(c.actor_id)))) as value
from
  commits_data c
where
  c.repo_group is not null
group by
  c.repo_group
union select 'pstat,All' as repo_group,
  'Code committers' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(c.actor_id)))) as value
from
  commits_data c
union select sub.repo_group,
  case sub.type
    when 'IssuesEvent' then 'Issue creators'
    when 'PullRequestEvent' then 'PR creators'
    when 'PushEvent' then 'Pushers'
    when 'PullRequestReviewCommentEvent' then 'PR review commenters'
    when 'PullRequestReviewEvent' then 'PR reviewers'
    when 'IssueCommentEvent' then 'Issue commenters'
    when 'CommitCommentEvent' then 'Commit commenters'
    when 'WatchEvent' then 'Stargazers/Watchers'
    when 'ForkEvent' then 'Forkers'
  end as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(sub.actor_id)))) as value
from (
  select 'pstat,' || r.repo_group as repo_group,
    e.type,
    e.actor_id
  from
    gha_repo_groups r,
    gha_events e
  where
    e.type in (
      'IssuesEvent', 'PullRequestEvent', 'PushEvent',
      'PullRequestReviewCommentEvent', 'IssueCommentEvent',
      'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
    )
    and {{period:e.created_at}}
    and e.repo_id = r.id
    and e.dup_repo_name = r.name
    and (lower(e.dup_actor_login) {{exclude_bots}})
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group,
  sub.type
union select 'pstat,All' as repo_group,
  case type 
    when 'IssuesEvent' then 'Issue creators'
    when 'PullRequestEvent' then 'PR creators'
    when 'PushEvent' then 'Pushers'
    when 'PullRequestReviewCommentEvent' then 'PR review commenters'
    when 'PullRequestReviewEvent' then 'PR reviewers'
    when 'IssueCommentEvent' then 'Issue commenters'
    when 'CommitCommentEvent' then 'Commit commenters'
    when 'WatchEvent' then 'Stargazers/Watchers'
    when 'ForkEvent' then 'Forkers'
  end as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)))) as value
from
  gha_events
where
  type in (
    'IssuesEvent', 'PullRequestEvent', 'PushEvent',
    'PullRequestReviewCommentEvent', 'IssueCommentEvent',
    'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
  )
  and {{period:created_at}}
  and (lower(dup_actor_login) {{exclude_bots}})
group by
  type
union select 'pstat,' || r.repo_group as repo_group,
  'Repositories' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.repo_id)))) as value
from
  gha_events e,
  gha_repo_groups r
where
  {{period:e.created_at}}
  and e.repo_id = r.id
  and e.dup_repo_name = r.name
  and r.repo_group is not null
group by
  r.repo_group
union select 'pstat,All' as repo_group,
  'Repositories' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(repo_id)))) as value
from
  gha_events
where
  {{period:created_at}}
union select sub.repo_group,
  'Comments' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(sub.id)))) as value
from (
  select 'pstat,' || r.repo_group as repo_group,
    c.id
  from
    gha_repo_groups r,
    gha_comments c
  where
    {{period:c.created_at}}
    and c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and (lower(c.dup_user_login) {{exclude_bots}})
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
union select 'pstat,All' as repo_group,
  'Comments' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as value
from
  gha_comments
where
  {{period:created_at}}
  and (lower(dup_user_login) {{exclude_bots}})
union select sub.repo_group,
  'Commenters' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(sub.user_id)))) as value
from (
  select 'pstat,' || r.repo_group as repo_group,
    c.user_id
  from
    gha_repo_groups r,
    gha_comments c
  where
    {{period:c.created_at}}
    and c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and (lower(c.dup_user_login) {{exclude_bots}})
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
union select 'pstat,All' as repo_group,
  'Commenters' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(user_id)))) as value
from
  gha_comments
where
  {{period:created_at}}
  and (lower(dup_user_login) {{exclude_bots}})
union select sub.repo_group,
  'PR reviews' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(sub.id)))) as value
from (
  select 'pstat,' || r.repo_group as repo_group,
    c.id
  from
    gha_repo_groups r,
    gha_reviews c
  where
    {{period:c.submitted_at}}
    and c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
    and (lower(c.dup_user_login) {{exclude_bots}})
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
union select 'pstat,All' as repo_group,
  'PR reviews' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as value
from
  gha_reviews
where
  {{period:submitted_at}}
  and (lower(dup_user_login) {{exclude_bots}})
union select sub.repo_group,
  'Issues' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(sub.id)))) as value
from (
  select 'pstat,' || r.repo_group as repo_group,
    i.id
  from
    gha_repo_groups r,
    gha_issues i
  where
    {{period:i.created_at}}
    and i.dup_repo_id = r.id
    and i.dup_repo_name = r.name
    and i.is_pull_request = false
    and (lower(i.dup_user_login) {{exclude_bots}})
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
union select 'pstat,All' as repo_group,
  'Issues' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as value
from
  gha_issues
where
  {{period:created_at}}
  and is_pull_request = false
  and (lower(dup_user_login) {{exclude_bots}})
union select sub.repo_group,
  'PRs' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(sub.id)))) as value
from (
  select 'pstat,' || r.repo_group as repo_group,
    i.id
  from
    gha_repo_groups r,
    gha_issues i
  where
    {{period:i.created_at}}
    and i.dup_repo_id = r.id
    and i.dup_repo_name = r.name
    and i.is_pull_request = true
    and (lower(i.dup_user_login) {{exclude_bots}})
 ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
union select 'pstat,All' as repo_group,
  'PRs' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as value
from
  gha_issues
where
  {{period:created_at}}
  and is_pull_request = true
  and (lower(dup_user_login) {{exclude_bots}})
union select sub.repo_group,
  'Events' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(sub.id)))) as value
from (
  select 'pstat,' || r.repo_group as repo_group,
    e.id
  from
    gha_repo_groups r,
    gha_events e
  where
    {{period:e.created_at}}
    and e.repo_id = r.id
    and e.dup_repo_name = r.name
    and (lower(e.dup_actor_login) {{exclude_bots}})
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
union select 'pstat,All' as repo_group,
  'Events' as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as value
from
  gha_events
where
  {{period:created_at}}
  and (lower(dup_actor_login) {{exclude_bots}})
order by
  name asc,
  value desc,
  repo_group asc
;
