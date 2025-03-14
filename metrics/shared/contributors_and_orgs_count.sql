with data as (
  select e.actor_id,
    e.dup_actor_login as actor_login,
    aa.company_name as company
  from
    gha_events e
  left join
    gha_actors_affiliations aa
  on
    aa.actor_id = e.actor_id
    and aa.dt_from <= e.created_at
    and aa.dt_to > e.created_at
  where
    e.created_at < '{{to}}'
    and e.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent')
    and (lower(e.dup_actor_login) {{exclude_bots}})
  union select c.author_id as actor_id,
    c.dup_author_login as actor_login,
    aa.company_name as company
  from
    gha_commits c
  left join
    gha_actors_affiliations aa
  on
    aa.actor_id = c.author_id
    and aa.dt_from <= c.dup_created_at
    and aa.dt_to > c.dup_created_at
  where
     c.author_id is not null
    and c.dup_created_at < '{{to}}'
    and (lower(c.dup_author_login) {{exclude_bots}})
  union select c.committer_id as actor_id,
    c.dup_committer_login as actor_login,
    aa.company_name as company
  from
    gha_commits c
  left join
    gha_actors_affiliations aa
  on
    aa.actor_id = c.committer_id
    and aa.dt_from <= c.dup_created_at
    and aa.dt_to > c.dup_created_at
  where
    c.committer_id is not null
    and c.dup_created_at < '{{to}}'
    and (lower(c.dup_committer_login) {{exclude_bots}})
)
select
  count(distinct actor_login) as contributors_count,
  count(distinct company) filter (where company != 'Independent') as orgs_count
from
  data
;
