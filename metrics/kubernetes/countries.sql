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

create temp table repos_in_groups_{{rnd}} as
select
  id as repo_id,
  name as repo_name,
  repo_group
from
  gha_repos
where
  repo_group is not null
  and repo_group in (select repo_group_name from trepo_groups)
;
create index on repos_in_groups_{{rnd}}(repo_id, repo_name);
analyze repos_in_groups_{{rnd}};

create temp table base_events_{{rnd}} as
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
  actors_country_{{rnd}} a
on
  a.actor_id = e.actor_id
where
  e.created_at >= '{{from}}'
  and e.created_at < '{{to}}'
;
analyze base_events_{{rnd}};

create temp table base_events_in_groups_{{rnd}} as
select
  b.id,
  b.type,
  b.actor_id,
  b.country_name,
  r.repo_group as repo_group_base
from
  base_events_{{rnd}} b
join
  repos_in_groups_{{rnd}} r
on
  r.repo_id = b.repo_id
  and r.repo_name = b.repo_name
;
analyze base_events_in_groups_{{rnd}};

create temp table ecf_event_groups_{{rnd}} as
select distinct
  ecf.event_id,
  ecf.repo_group
from
  base_events_in_groups_{{rnd}} b
join
  gha_events_commits_files ecf
on
  ecf.event_id = b.id
;
create index on ecf_event_groups_{{rnd}}(event_id);
analyze ecf_event_groups_{{rnd}};

create temp table grouped_events_{{rnd}} as
select distinct
  b.id,
  b.type,
  b.actor_id,
  b.country_name,
  coalesce(ecf.repo_group, b.repo_group_base) as repo_group
from
  base_events_in_groups_{{rnd}} b
left join
  ecf_event_groups_{{rnd}} ecf
on
  ecf.event_id = b.id
;
analyze grouped_events_{{rnd}};

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
    base_events_{{rnd}}
  group by
    country_name

  union all

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
    grouped_events_{{rnd}}
  group by
    country_name,
    repo_group
) inn
where
  inn.repo_group is not null
order by
  name
;

