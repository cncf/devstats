create temp table pcs_ok_logins_{{rnd}} as
select login from (
  select distinct lower(e.dup_actor_login) as login from gha_events e where {{period:e.created_at}}
  union
  select distinct lower(c.dup_user_login) from gha_comments c where {{period:c.created_at}}
  union
  select distinct lower(r.dup_user_login) from gha_reviews r where {{period:r.submitted_at}}
  union
  select distinct lower(i.dup_user_login) from gha_issues i where {{period:i.created_at}}
  union
  select distinct lower(c.dup_actor_login) from gha_commits c where {{period:c.dup_created_at}}
  union
  select distinct lower(c.dup_author_login) from gha_commits c where {{period:c.dup_created_at}}
  union
  select distinct lower(c.dup_committer_login) from gha_commits c where {{period:c.dup_created_at}}
) sub
where
  (login {{exclude_bots}})
;
create index on pcs_ok_logins_{{rnd}} (login);
analyze pcs_ok_logins_{{rnd}};

create temp table pcs_events_ok_{{rnd}} as
select
  e.id,
  e.type,
  e.actor_id,
  e.repo_id,
  e.created_at
from
  gha_events e
where
  {{period:e.created_at}}
  and lower(e.dup_actor_login) in (select login from pcs_ok_logins_{{rnd}})
;
analyze pcs_events_ok_{{rnd}};

create temp table pcs_comments_ok_{{rnd}} as
select
  c.id,
  c.user_id,
  c.created_at
from
  gha_comments c
where
  {{period:c.created_at}}
  and lower(c.dup_user_login) in (select login from pcs_ok_logins_{{rnd}})
;
analyze pcs_comments_ok_{{rnd}};

create temp table pcs_reviews_ok_{{rnd}} as
select
  r.id,
  r.user_id,
  r.submitted_at as created_at
from
  gha_reviews r
where
  {{period:r.submitted_at}}
  and lower(r.dup_user_login) in (select login from pcs_ok_logins_{{rnd}})
;
analyze pcs_reviews_ok_{{rnd}};

create temp table pcs_issues_ok_{{rnd}} as
select
  i.id,
  i.user_id,
  i.created_at,
  i.is_pull_request
from
  gha_issues i
where
  {{period:i.created_at}}
  and lower(i.dup_user_login) in (select login from pcs_ok_logins_{{rnd}})
;
analyze pcs_issues_ok_{{rnd}};

create temp table pcs_commits_ok_{{rnd}} as
select
  c.sha,
  v.actor_id,
  c.dup_created_at as created_at
from
  gha_commits c
cross join lateral
  (values
    ('actor', c.dup_actor_id, c.dup_actor_login),
    ('author', c.author_id, c.dup_author_login),
    ('committer', c.committer_id, c.dup_committer_login)
  ) v(role, actor_id, login)
where
  {{period:c.dup_created_at}}
  and (v.role = 'actor' or v.actor_id is not null)
  and lower(v.login) in (select login from pcs_ok_logins_{{rnd}})
;
analyze pcs_commits_ok_{{rnd}};

create temp table pcs_events_company_{{rnd}} as
select
  e.id,
  e.type,
  e.actor_id,
  e.repo_id,
  af.company_name as company
from
  pcs_events_ok_{{rnd}} e,
  gha_actors_affiliations af
where
  e.actor_id = af.actor_id
  and af.dt_from <= e.created_at
  and af.dt_to > e.created_at
  and af.company_name != ''
;
analyze pcs_events_company_{{rnd}};

create temp table pcs_comments_company_{{rnd}} as
select
  c.id,
  c.user_id,
  af.company_name as company
from
  pcs_comments_ok_{{rnd}} c,
  gha_actors_affiliations af
where
  c.user_id = af.actor_id
  and af.dt_from <= c.created_at
  and af.dt_to > c.created_at
  and af.company_name != ''
;
analyze pcs_comments_company_{{rnd}};

create temp table pcs_reviews_company_{{rnd}} as
select
  r.id,
  r.user_id,
  af.company_name as company
from
  pcs_reviews_ok_{{rnd}} r,
  gha_actors_affiliations af
where
  r.user_id = af.actor_id
  and af.dt_from <= r.created_at
  and af.dt_to > r.created_at
  and af.company_name != ''
;
analyze pcs_reviews_company_{{rnd}};

create temp table pcs_issues_company_{{rnd}} as
select
  i.id,
  i.user_id,
  i.is_pull_request,
  af.company_name as company
from
  pcs_issues_ok_{{rnd}} i,
  gha_actors_affiliations af
where
  i.user_id = af.actor_id
  and af.dt_from <= i.created_at
  and af.dt_to > i.created_at
  and af.company_name != ''
;
analyze pcs_issues_company_{{rnd}};

create temp table pcs_commits_company_{{rnd}} as
select
  c.sha,
  c.actor_id,
  af.company_name as company
from
  pcs_commits_ok_{{rnd}} c,
  gha_actors_affiliations af
where
  c.actor_id = af.actor_id
  and af.dt_from <= c.created_at
  and af.dt_to > c.created_at
  and af.company_name != ''
;
analyze pcs_commits_company_{{rnd}};

select
  'hcom,' || sub.metric as metric,
  sub.company as name,
  sub.value as value
from (
  select 'Commits' as metric,
    company,
    count(distinct sha) as value
  from
    pcs_commits_company_{{rnd}}
  group by
    company
  union select 'Committers' as metric,
    company,
    count(distinct actor_id) as value
  from
    pcs_commits_company_{{rnd}}
  group by
    company
  union select case e.type
      when 'IssuesEvent' then 'Issue creators'
      when 'PullRequestEvent' then 'PR creators'
      when 'PushEvent' then 'Pushers'
      when 'PullRequestReviewEvent' then 'PR reviewers'
      when 'PullRequestReviewCommentEvent' then 'PR review commenters'
      when 'IssueCommentEvent' then 'Issue commenters'
      when 'CommitCommentEvent' then 'Commit commenters'
      when 'WatchEvent' then 'Watchers'
      when 'ForkEvent' then 'Forkers'
    end as metric,
    e.company as company,
    count(distinct e.actor_id) as value
  from
    pcs_events_company_{{rnd}} e
  where
    e.type in (
      'IssuesEvent', 'PullRequestEvent', 'PushEvent',
      'PullRequestReviewCommentEvent', 'IssueCommentEvent',
      'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
    )
  group by
    e.type,
    e.company
  union select 'Contributors' as metric,
    e.company as company,
    count(distinct e.actor_id) as value
  from
    pcs_events_company_{{rnd}} e
  where
    e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  group by
    e.company
  union select 'Contributions' as metric,
    e.company as company,
    count(distinct e.id) as value
  from
    pcs_events_company_{{rnd}} e
  where
    e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  group by
    e.company
  union select 'Repositories' as metric,
    e.company as company,
    count(distinct e.repo_id) as value
  from
    pcs_events_company_{{rnd}} e
  group by
    e.company
  union select 'Comments' as metric,
    c.company as company,
    count(distinct c.id) as value
  from
    pcs_comments_company_{{rnd}} c
  group by
    c.company
  union select 'Commenters' as metric,
    c.company as company,
    count(distinct c.user_id) as value
  from
    pcs_comments_company_{{rnd}} c
  group by
    c.company
  union select 'PR reviews' as metric,
    r.company as company,
    count(distinct r.id) as value
  from
    pcs_reviews_company_{{rnd}} r
  group by
    r.company
  union select 'Issues' as metric,
    i.company as company,
    count(distinct i.id) as value
  from
    pcs_issues_company_{{rnd}} i
  where
    i.is_pull_request = false
  group by
    i.company
  union select 'PRs' as metric,
    i.company as company,
    count(distinct i.id) as value
  from
    pcs_issues_company_{{rnd}} i
  where
    i.is_pull_request = true
  group by
    i.company
  union select 'Events' as metric,
    e.company as company,
    count(e.id) as value
  from
    pcs_events_company_{{rnd}} e
  group by
    e.company
  union select 'Commits' as metric,
    'All',
    count(distinct sha) as value
  from
    pcs_commits_ok_{{rnd}}
  union select 'Committers' as metric,
    'All',
    count(distinct actor_id) as value
  from
    pcs_commits_ok_{{rnd}}
  union select case e.type
      when 'IssuesEvent' then 'Issue creators'
      when 'PullRequestEvent' then 'PR creators'
      when 'PushEvent' then 'Pushers'
      when 'PullRequestReviewEvent' then 'PR reviewers'
      when 'PullRequestReviewCommentEvent' then 'PR review commenters'
      when 'IssueCommentEvent' then 'Issue commenters'
      when 'CommitCommentEvent' then 'Commit commenters'
      when 'WatchEvent' then 'Watchers'
      when 'ForkEvent' then 'Forkers'
    end as metric,
    'All' as company,
    count(distinct e.actor_id) as value
  from
    pcs_events_ok_{{rnd}} e
  where
    e.type in (
      'IssuesEvent', 'PullRequestEvent', 'PushEvent',
      'PullRequestReviewCommentEvent', 'IssueCommentEvent',
      'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
    )
  group by
    e.type
  union select 'Contributors' as metric,
    'All' as company,
    count(distinct e.actor_id) as value
  from
    pcs_events_ok_{{rnd}} e
  where
    e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  union select 'Contributions' as metric,
    'All' as company,
    count(distinct e.id) as value
  from
    pcs_events_ok_{{rnd}} e
  where
    e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  union select 'Repositories' as metric,
    'All' as company,
    count(distinct e.repo_id) as value
  from
    pcs_events_ok_{{rnd}} e
  union select 'Comments' as metric,
    'All' as company,
    count(distinct c.id) as value
  from
    pcs_comments_ok_{{rnd}} c
  union select 'Commenters' as metric,
    'All' as company,
    count(distinct c.user_id) as value
  from
    pcs_comments_ok_{{rnd}} c
  union select 'PR reviews' as metric,
    'All' as company,
    count(distinct r.id) as value
  from
    pcs_reviews_ok_{{rnd}} r
  union select 'Issues' as metric,
    'All' as company,
    count(distinct i.id) as value
  from
    pcs_issues_ok_{{rnd}} i
  where
    i.is_pull_request = false
  union select 'PRs' as metric,
    'All' as company,
    count(distinct i.id) as value
  from
    pcs_issues_ok_{{rnd}} i
  where
    i.is_pull_request = true
  union select 'Events' as metric,
    'All' as company,
    count(e.id) as value
  from
    pcs_events_ok_{{rnd}} e
  ) sub
where
  (sub.metric = 'Commenters' and sub.value > 2 * {{project_scale}} * sqrt({{range}}/1450.0))
  or (sub.metric = 'Comments' and sub.value > 3 * {{project_scale}} * sqrt({{range}}/1450.0))
  or (sub.metric = 'PR reviews' and sub.value > 2 * {{project_scale}} * sqrt({{range}}/1450.0))
  or (sub.metric = 'Events' and sub.value > 10 * {{project_scale}} * sqrt({{range}}/1450.0))
  or (sub.metric = 'Forkers' and sub.value > 2 * {{project_scale}} * sqrt({{range}}/1450.0))
  or (sub.metric = 'Issue commenters' and sub.value > 1 * {{project_scale}} * sqrt({{range}}/1450.0))
  or (sub.metric = 'Issue creators' and sub.value > 1 * {{project_scale}} * sqrt({{range}}/1450.0))
  or (sub.metric = 'Issues' and sub.value > 1 * {{project_scale}} * sqrt({{range}}/1450.0))
  or (sub.metric = 'PR creators' and sub.value > 1 * {{project_scale}} * sqrt({{range}}/1450.0))
  or (sub.metric = 'PR reviewers' and sub.value > 1 * {{project_scale}} * sqrt({{range}}/1450.0))
  or (sub.metric = 'PR review commenters' and sub.value > 1 * {{project_scale}} * sqrt({{range}}/1450.0))
  or (sub.metric = 'PRs' and sub.value > 1 * {{project_scale}} * sqrt({{range}}/1450.0))
  or (sub.metric = 'Repositories' and sub.value > 1 * {{project_scale}} * sqrt({{range}}/1450.0))
  or (sub.metric = 'Watchers' and sub.value > 3 * {{project_scale}} * sqrt({{range}}/1450.0))
  or (sub.metric in (
      'Commit commenters',
      'Commits',
      'Committers',
      'Pushers',
      'Contributors',
      'Contributions'
    ) and sub.value > 0.2 * {{project_scale}} * sqrt({{range}}/1450.0))
order by
  metric asc,
  value desc,
  name asc
;
