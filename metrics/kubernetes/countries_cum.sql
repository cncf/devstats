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

create temp table events_in_groups_{{rnd}} as
select
  e.id,
  e.actor_id,
  e.type,
  a.country_name,
  r.repo_group as base_repo_group
from
  gha_events e
join
  actors_country_{{rnd}} a
on
  a.actor_id = e.actor_id
join
  repos_in_groups_{{rnd}} r
on
  r.repo_id = e.repo_id
  and r.repo_name = e.dup_repo_name
where
  e.created_at < '{{to}}'
;
create index on events_in_groups_{{rnd}}(id);
create index on events_in_groups_{{rnd}}(actor_id);
analyze events_in_groups_{{rnd}};

create temp table ecf_event_flags_{{rnd}} as
select
  ecf.event_id,
  bool_or(ecf.repo_group is null) as has_null
from
  gha_events_commits_files ecf
join
  events_in_groups_{{rnd}} e
on
  e.id = ecf.event_id
group by
  ecf.event_id
;
create index on ecf_event_flags_{{rnd}}(event_id);
analyze ecf_event_flags_{{rnd}};

create temp table ecf_event_groups_{{rnd}} as
select distinct
  ecf.event_id,
  ecf.repo_group
from
  gha_events_commits_files ecf
join
  events_in_groups_{{rnd}} e
on
  e.id = ecf.event_id
where
  ecf.repo_group is not null
;
create index on ecf_event_groups_{{rnd}}(event_id);
create index on ecf_event_groups_{{rnd}}(repo_group);
analyze ecf_event_groups_{{rnd}};

create temp table event_repo_groups_{{rnd}} as
select distinct
  x.event_id,
  x.repo_group
from (
  select
    event_id,
    repo_group
  from
    ecf_event_groups_{{rnd}}
  union all
  select
    e.id as event_id,
    e.base_repo_group as repo_group
  from
    events_in_groups_{{rnd}} e
  left join
    ecf_event_flags_{{rnd}} f
  on
    f.event_id = e.id
  where
    f.event_id is null
    or f.has_null
) x
;
create index on event_repo_groups_{{rnd}}(event_id);
create index on event_repo_groups_{{rnd}}(repo_group);
analyze event_repo_groups_{{rnd}};

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
    'countriescum' as type,
    a.country_name,
    'all' as repo_group,
    count(distinct e.actor_id) filter (
      where e.type in (
        'IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent',
        'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent'
      )
    ) as contributors,
    count(*) filter (
      where e.type in (
        'IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent',
        'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent'
      )
    ) as contributions,
    count(distinct e.actor_id) as users,
    count(*) as events,
    count(distinct e.actor_id) filter (where e.type = 'PushEvent') as committers,
    count(*) filter (where e.type = 'PushEvent') as commits,
    count(distinct e.actor_id) filter (where e.type = 'PullRequestEvent') as prcreators,
    count(*) filter (where e.type = 'PullRequestEvent') as prs,
    count(distinct e.actor_id) filter (where e.type = 'IssuesEvent') as issuecreators,
    count(*) filter (where e.type = 'IssuesEvent') as issues,
    count(distinct e.actor_id) filter (where e.type in ('CommitCommentEvent', 'IssueCommentEvent')) as commenters,
    count(*) filter (where e.type in ('CommitCommentEvent', 'IssueCommentEvent')) as comments,
    count(distinct e.actor_id) filter (where e.type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent')) as reviewers,
    count(*) filter (where e.type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent')) as reviews,
    count(distinct e.actor_id) filter (where e.type = 'WatchEvent') as watchers,
    count(*) filter (where e.type = 'WatchEvent') as watches,
    count(distinct e.actor_id) filter (where e.type = 'ForkEvent') as forkers,
    count(*) filter (where e.type = 'ForkEvent') as forks
  from
    gha_events e
  join
    actors_country_{{rnd}} a
  on
    a.actor_id = e.actor_id
  where
    e.created_at < '{{to}}'
  group by
    a.country_name

  union

  select
    'countriescum' as type,
    e.country_name,
    g.repo_group as repo_group,
    count(distinct e.actor_id) filter (
      where e.type in (
        'IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent',
        'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent'
      )
    ) as contributors,
    count(*) filter (
      where e.type in (
        'IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent',
        'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent'
      )
    ) as contributions,
    count(distinct e.actor_id) as users,
    count(*) as events,
    count(distinct e.actor_id) filter (where e.type = 'PushEvent') as committers,
    count(*) filter (where e.type = 'PushEvent') as commits,
    count(distinct e.actor_id) filter (where e.type = 'PullRequestEvent') as prcreators,
    count(*) filter (where e.type = 'PullRequestEvent') as prs,
    count(distinct e.actor_id) filter (where e.type = 'IssuesEvent') as issuecreators,
    count(*) filter (where e.type = 'IssuesEvent') as issues,
    count(distinct e.actor_id) filter (where e.type in ('CommitCommentEvent', 'IssueCommentEvent')) as commenters,
    count(*) filter (where e.type in ('CommitCommentEvent', 'IssueCommentEvent')) as comments,
    count(distinct e.actor_id) filter (where e.type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent')) as reviewers,
    count(*) filter (where e.type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent')) as reviews,
    count(distinct e.actor_id) filter (where e.type = 'WatchEvent') as watchers,
    count(*) filter (where e.type = 'WatchEvent') as watches,
    count(distinct e.actor_id) filter (where e.type = 'ForkEvent') as forkers,
    count(*) filter (where e.type = 'ForkEvent') as forks
  from
    events_in_groups_{{rnd}} e
  join
    event_repo_groups_{{rnd}} g
  on
    g.event_id = e.id
  group by
    e.country_name,
    g.repo_group
) inn
where
  inn.repo_group is not null
order by
  name
;

