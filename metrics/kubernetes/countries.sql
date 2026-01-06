with base_events as (
  select
    e.id,
    e.repo_id,
    e.dup_repo_name as repo_name,
    e.type,
    e.actor_id,
    a.country_name
  from
    gha_events e
  join
    gha_actors a
  on
    a.id = e.actor_id
  where
    (lower(a.login) {{exclude_bots}})
    and a.country_name is not null
    and a.country_name != ''
    and e.created_at >= '{{from}}'
    and e.created_at < '{{to}}'
), all_country as (
  select
    'countries' as type,
    country_name,
    'all' as repo_group,
    count(distinct actor_id) filter (
      where type in (
        'IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent',
        'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent'
      )
    ) as contributors,
    count(distinct id) filter (
      where type in (
        'IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent',
        'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent'
      )
    ) as contributions,
    count(distinct actor_id) as users,
    count(distinct id) as events,
    count(distinct actor_id) filter (where type = 'PushEvent') as committers,
    count(distinct id) filter (where type = 'PushEvent') as commits,
    count(distinct actor_id) filter (where type = 'PullRequestEvent') as prcreators,
    count(distinct id) filter (where type = 'PullRequestEvent') as prs,
    count(distinct actor_id) filter (where type = 'IssuesEvent') as issuecreators,
    count(distinct id) filter (where type = 'IssuesEvent') as issues,
    count(distinct actor_id) filter (where type in ('CommitCommentEvent', 'IssueCommentEvent')) as commenters,
    count(distinct id) filter (where type in ('CommitCommentEvent', 'IssueCommentEvent')) as comments,
    count(distinct actor_id) filter (where type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent')) as reviewers,
    count(distinct id) filter (where type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent')) as reviews,
    count(distinct actor_id) filter (where type = 'WatchEvent') as watchers,
    count(distinct id) filter (where type = 'WatchEvent') as watches,
    count(distinct actor_id) filter (where type = 'ForkEvent') as forkers,
    count(distinct id) filter (where type = 'ForkEvent') as forks
  from
    base_events
  group by
    country_name
), grouped_events as (
  select distinct
    b.id,
    b.type,
    b.actor_id,
    b.country_name,
    coalesce(ecf.repo_group, r.repo_group) as repo_group
  from
    base_events b
  join
    gha_repos r
  on
    r.id = b.repo_id
    and r.name = b.repo_name
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = b.id
  where
    r.repo_group in (select repo_group_name from trepo_groups)
), by_country_repo_group as (
  select
    'countries' as type,
    country_name,
    repo_group,
    count(distinct actor_id) filter (
      where type in (
        'IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent',
        'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent'
      )
    ) as contributors,
    count(distinct id) filter (
      where type in (
        'IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent',
        'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent'
      )
    ) as contributions,
    count(distinct actor_id) as users,
    count(distinct id) as events,
    count(distinct actor_id) filter (where type = 'PushEvent') as committers,
    count(distinct id) filter (where type = 'PushEvent') as commits,
    count(distinct actor_id) filter (where type = 'PullRequestEvent') as prcreators,
    count(distinct id) filter (where type = 'PullRequestEvent') as prs,
    count(distinct actor_id) filter (where type = 'IssuesEvent') as issuecreators,
    count(distinct id) filter (where type = 'IssuesEvent') as issues,
    count(distinct actor_id) filter (where type in ('CommitCommentEvent', 'IssueCommentEvent')) as commenters,
    count(distinct id) filter (where type in ('CommitCommentEvent', 'IssueCommentEvent')) as comments,
    count(distinct actor_id) filter (where type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent')) as reviewers,
    count(distinct id) filter (where type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent')) as reviews,
    count(distinct actor_id) filter (where type = 'WatchEvent') as watchers,
    count(distinct id) filter (where type = 'WatchEvent') as watches,
    count(distinct actor_id) filter (where type = 'ForkEvent') as forkers,
    count(distinct id) filter (where type = 'ForkEvent') as forks
  from
    grouped_events
  group by
    country_name,
    repo_group
)
select
  concat(
    inn.type, ';', inn.country_name, '`', inn.repo_group, ';',
    'contributors,contributions,users,events,committers,commits,prcreators,prs,issuecreators,issues,commenters,comments,reviewers,reviews,watchers,watches,forkers,forks'
  ) as name,
  inn.contributors,
  inn.contributions,
  inn.users,
  inn.events,
  inn.committers,
  inn.commits,
  inn.prcreators,
  inn.prs,
  inn.issuecreators,
  inn.issues,
  inn.commenters,
  inn.comments,
  inn.reviewers,
  inn.reviews,
  inn.watchers,
  inn.watches,
  inn.forkers,
  inn.forks
from (
  select * from all_country
  union all
  select * from by_country_repo_group
) inn
where
  inn.repo_group is not null
order by
  name
;

