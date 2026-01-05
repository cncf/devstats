create temp table hdev_repos_{{rnd}} as
select distinct
  repo_name
from
  trepos
;
create index on hdev_repos_{{rnd}} (repo_name);
analyze hdev_repos_{{rnd}};

create temp table hdev_commits_base_{{rnd}} as
select
  c.dup_repo_name as repo,
  c.sha,
  c.dup_created_at,
  c.dup_actor_id,
  c.dup_actor_login,
  c.author_id,
  c.dup_author_login,
  c.committer_id,
  c.dup_committer_login
from
  gha_commits c
where
  {{period:c.dup_created_at}}
;
create index on hdev_commits_base_{{rnd}} (repo);
create index on hdev_commits_base_{{rnd}} (dup_created_at);
analyze hdev_commits_base_{{rnd}};

create temp table hdev_commits_data_{{rnd}} as
select
  z.repo,
  z.sha,
  z.actor_id,
  z.actor_login,
  z.company
from (
  select
    x.repo,
    x.sha,
    x.actor_id,
    x.actor_login,
    coalesce(aa.company_name, '') as company
  from (
    select
      c.repo,
      c.sha,
      v.actor_id,
      v.actor_login,
      c.dup_created_at
    from
      hdev_commits_base_{{rnd}} c
    cross join lateral (
      values
        (c.dup_actor_id, c.dup_actor_login, true),
        (c.author_id, c.dup_author_login, c.author_id is not null),
        (c.committer_id, c.dup_committer_login, c.committer_id is not null)
    ) v(actor_id, actor_login, ok)
    where
      v.ok
      and (lower(v.actor_login) {{exclude_bots}})
  ) x
  left join
    gha_actors_affiliations aa
  on
    aa.actor_id = x.actor_id
    and aa.dt_from <= x.dup_created_at
    and aa.dt_to > x.dup_created_at
  union all
  select
    cr.dup_repo_name as repo,
    cr.sha,
    cr.actor_id,
    cr.actor_login,
    coalesce(aa.company_name, '') as company
  from
    gha_commits_roles cr
  left join
    gha_actors_affiliations aa
  on
    aa.actor_id = cr.actor_id
    and aa.dt_from <= cr.dup_created_at
    and aa.dt_to > cr.dup_created_at
  where
    cr.actor_id is not null
    and cr.actor_id <> 0
    and cr.role = 'Co-authored-by'
    and {{period:cr.dup_created_at}}
    and (lower(cr.actor_login) {{exclude_bots}})
) z
group by
  z.repo,
  z.sha,
  z.actor_id,
  z.actor_login,
  z.company
;
create index on hdev_commits_data_{{rnd}} (repo);
create index on hdev_commits_data_{{rnd}} (actor_id);
create index on hdev_commits_data_{{rnd}} (actor_login);
analyze hdev_commits_data_{{rnd}};

create temp table hdev_events_base_{{rnd}} as
select
  e.id,
  e.type,
  e.repo_id,
  e.dup_repo_name as repo,
  e.actor_id,
  e.dup_actor_login as author,
  lower(e.dup_actor_login) as author_lower,
  coalesce(aa.company_name, '') as company
from
  gha_events e
left join
  gha_actors_affiliations aa
on
  aa.actor_id = e.actor_id
  and aa.dt_from <= e.created_at
  and aa.dt_to > e.created_at
where
  {{period:e.created_at}}
;
create index on hdev_events_base_{{rnd}} (repo);
create index on hdev_events_base_{{rnd}} (type, repo);
create index on hdev_events_base_{{rnd}} (actor_id);
create index on hdev_events_base_{{rnd}} (author);
analyze hdev_events_base_{{rnd}};

create temp table hdev_comments_base_{{rnd}} as
select
  c.id,
  c.dup_repo_name as repo,
  c.user_id,
  c.dup_user_login as author,
  lower(c.dup_user_login) as author_lower,
  coalesce(aa.company_name, '') as company
from
  gha_comments c
left join
  gha_actors_affiliations aa
on
  aa.actor_id = c.user_id
  and aa.dt_from <= c.created_at
  and aa.dt_to > c.created_at
where
  {{period:c.created_at}}
;
create index on hdev_comments_base_{{rnd}} (repo);
create index on hdev_comments_base_{{rnd}} (user_id);
create index on hdev_comments_base_{{rnd}} (author);
analyze hdev_comments_base_{{rnd}};

create temp table hdev_issues_base_{{rnd}} as
select
  i.id,
  i.dup_repo_name as repo,
  i.user_id,
  i.dup_user_login as author,
  lower(i.dup_user_login) as author_lower,
  i.is_pull_request,
  coalesce(aa.company_name, '') as company
from
  gha_issues i
left join
  gha_actors_affiliations aa
on
  aa.actor_id = i.user_id
  and aa.dt_from <= i.created_at
  and aa.dt_to > i.created_at
where
  {{period:i.created_at}}
;
create index on hdev_issues_base_{{rnd}} (repo);
create index on hdev_issues_base_{{rnd}} (user_id);
create index on hdev_issues_base_{{rnd}} (author);
create index on hdev_issues_base_{{rnd}} (is_pull_request);
analyze hdev_issues_base_{{rnd}};

create temp table hdev_merged_prs_base_{{rnd}} as
select
  pr.id,
  pr.dup_repo_name as repo,
  pr.user_id,
  pr.dup_user_login as author,
  lower(pr.dup_user_login) as author_lower,
  coalesce(aa.company_name, '') as company
from
  gha_pull_requests pr
left join
  gha_actors_affiliations aa
on
  aa.actor_id = pr.user_id
  and aa.dt_from <= pr.merged_at
  and aa.dt_to > pr.merged_at
where
  pr.merged_at is not null
  and {{period:pr.merged_at}}
;
create index on hdev_merged_prs_base_{{rnd}} (repo);
create index on hdev_merged_prs_base_{{rnd}} (user_id);
create index on hdev_merged_prs_base_{{rnd}} (author);
analyze hdev_merged_prs_base_{{rnd}};

create temp table hdev_actors_country_{{rnd}} as
select
  id,
  login,
  lower(login) as login_lower,
  country_name
from
  gha_actors
where
  country_name is not null
;
create index on hdev_actors_country_{{rnd}} (id);
create index on hdev_actors_country_{{rnd}} (login);
analyze hdev_actors_country_{{rnd}};

create temp table hdev_events_country_{{rnd}} as
select
  e.id,
  e.type,
  e.repo,
  e.repo_id,
  a.country_name as country,
  a.login as author,
  lower(a.login) as author_lower,
  e.author_lower as event_author_lower,
  e.company
from
  hdev_events_base_{{rnd}} e
join
  hdev_actors_country_{{rnd}} a
on
  e.actor_id = a.id
union all
select
  e.id,
  e.type,
  e.repo,
  e.repo_id,
  a.country_name as country,
  a.login as author,
  lower(a.login) as author_lower,
  e.author_lower as event_author_lower,
  e.company
from
  hdev_events_base_{{rnd}} e
join
  hdev_actors_country_{{rnd}} a
on
  e.author = a.login
where
  e.actor_id is null
  or e.actor_id <> a.id
;
create index on hdev_events_country_{{rnd}} (repo);
create index on hdev_events_country_{{rnd}} (country);
create index on hdev_events_country_{{rnd}} (author);
create index on hdev_events_country_{{rnd}} (type);
analyze hdev_events_country_{{rnd}};

create temp table hdev_comments_country_{{rnd}} as
select
  c.id,
  c.repo,
  a.country_name as country,
  a.login as author,
  lower(a.login) as author_lower,
  c.company
from
  hdev_comments_base_{{rnd}} c
join
  hdev_actors_country_{{rnd}} a
on
  c.user_id = a.id
union all
select
  c.id,
  c.repo,
  a.country_name as country,
  a.login as author,
  lower(a.login) as author_lower,
  c.company
from
  hdev_comments_base_{{rnd}} c
join
  hdev_actors_country_{{rnd}} a
on
  c.author = a.login
where
  c.user_id is null
  or c.user_id <> a.id
;
create index on hdev_comments_country_{{rnd}} (repo);
create index on hdev_comments_country_{{rnd}} (country);
create index on hdev_comments_country_{{rnd}} (author);
analyze hdev_comments_country_{{rnd}};

create temp table hdev_issues_country_{{rnd}} as
select
  i.id,
  i.repo,
  i.is_pull_request,
  a.country_name as country,
  a.login as author,
  lower(a.login) as author_lower,
  i.company
from
  hdev_issues_base_{{rnd}} i
join
  hdev_actors_country_{{rnd}} a
on
  i.user_id = a.id
union all
select
  i.id,
  i.repo,
  i.is_pull_request,
  a.country_name as country,
  a.login as author,
  lower(a.login) as author_lower,
  i.company
from
  hdev_issues_base_{{rnd}} i
join
  hdev_actors_country_{{rnd}} a
on
  i.author = a.login
where
  i.user_id is null
  or i.user_id <> a.id
;
create index on hdev_issues_country_{{rnd}} (repo);
create index on hdev_issues_country_{{rnd}} (country);
create index on hdev_issues_country_{{rnd}} (author);
create index on hdev_issues_country_{{rnd}} (is_pull_request);
analyze hdev_issues_country_{{rnd}};

create temp table hdev_merged_prs_country_{{rnd}} as
select
  pr.id,
  pr.repo,
  a.country_name as country,
  a.login as author,
  lower(a.login) as author_lower,
  pr.company
from
  hdev_merged_prs_base_{{rnd}} pr
join
  hdev_actors_country_{{rnd}} a
on
  pr.user_id = a.id
union all
select
  pr.id,
  pr.repo,
  a.country_name as country,
  a.login as author,
  lower(a.login) as author_lower,
  pr.company
from
  hdev_merged_prs_base_{{rnd}} pr
join
  hdev_actors_country_{{rnd}} a
on
  pr.author = a.login
where
  pr.user_id is null
  or pr.user_id <> a.id
;
create index on hdev_merged_prs_country_{{rnd}} (repo);
create index on hdev_merged_prs_country_{{rnd}} (country);
create index on hdev_merged_prs_country_{{rnd}} (author);
analyze hdev_merged_prs_country_{{rnd}};

with
all_all_sub as (
  select
    'commits' as metric,
    actor_login as author,
    company,
    count(distinct sha) as value
  from
    hdev_commits_data_{{rnd}}
  group by
    actor_login,
    company
  union all
  select
    case type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    author,
    company,
    count(id) as value
  from
    hdev_events_base_{{rnd}}
  where
    type in (
      'PushEvent',
      'PullRequestReviewCommentEvent',
      'IssueCommentEvent',
      'CommitCommentEvent'
    )
    and (author_lower {{exclude_bots}})
  group by
    type,
    author,
    company
  union all
  select
    'contributions' as metric,
    author,
    company,
    count(id) as value
  from
    hdev_events_base_{{rnd}}
  where
    type in (
      'PushEvent',
      'PullRequestEvent',
      'IssuesEvent',
      'PullRequestReviewEvent',
      'CommitCommentEvent',
      'IssueCommentEvent',
      'PullRequestReviewCommentEvent'
    )
    and (author_lower {{exclude_bots}})
  group by
    author,
    company
  union all
  select
    'active_repos' as metric,
    author,
    company,
    count(distinct repo_id) as value
  from
    hdev_events_base_{{rnd}}
  where
    (author_lower {{exclude_bots}})
  group by
    author,
    company
  union all
  select
    'comments' as metric,
    author,
    company,
    count(distinct id) as value
  from
    hdev_comments_base_{{rnd}}
  where
    (author_lower {{exclude_bots}})
  group by
    author,
    company
  union all
  select
    'issues' as metric,
    author,
    company,
    count(distinct id) as value
  from
    hdev_issues_base_{{rnd}}
  where
    is_pull_request = false
    and (author_lower {{exclude_bots}})
  group by
    author,
    company
  union all
  select
    'prs' as metric,
    author,
    company,
    count(distinct id) as value
  from
    hdev_issues_base_{{rnd}}
  where
    is_pull_request = true
    and (author_lower {{exclude_bots}})
  group by
    author,
    company
  union all
  select
    'merged_prs' as metric,
    author,
    company,
    count(distinct id) as value
  from
    hdev_merged_prs_base_{{rnd}}
  where
    (author_lower {{exclude_bots}})
  group by
    author,
    company
  union all
  select
    'events' as metric,
    author,
    company,
    count(id) as value
  from
    hdev_events_base_{{rnd}}
  where
    (author_lower {{exclude_bots}})
  group by
    author,
    company
),
repo_sub as (
  select
    'commits' as metric,
    c.repo,
    c.actor_login as author,
    c.company,
    count(distinct c.sha) as value
  from
    hdev_commits_data_{{rnd}} c
  join
    hdev_repos_{{rnd}} r
  on
    r.repo_name = c.repo
  group by
    c.repo,
    c.actor_login,
    c.company
  union all
  select
    case e.type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'raw_reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    e.repo,
    e.author,
    e.company,
    count(distinct e.id) as value
  from
    hdev_events_base_{{rnd}} e
  join
    hdev_repos_{{rnd}} r
  on
    r.repo_name = e.repo
  where
    e.type in (
      'PushEvent',
      'PullRequestReviewCommentEvent',
      'PullRequestReviewEvent',
      'IssueCommentEvent',
      'CommitCommentEvent'
    )
    and (e.author_lower {{exclude_bots}})
  group by
    e.type,
    e.repo,
    e.author,
    e.company
  union all
  select
    'contributions' as metric,
    e.repo,
    e.author,
    e.company,
    count(distinct e.id) as value
  from
    hdev_events_base_{{rnd}} e
  join
    hdev_repos_{{rnd}} r
  on
    r.repo_name = e.repo
  where
    e.type in (
      'PushEvent',
      'PullRequestEvent',
      'IssuesEvent',
      'PullRequestReviewEvent',
      'CommitCommentEvent',
      'IssueCommentEvent',
      'PullRequestReviewCommentEvent'
    )
    and (e.author_lower {{exclude_bots}})
  group by
    e.repo,
    e.author,
    e.company
  union all
  select
    'active_repos' as metric,
    e.repo,
    e.author,
    e.company,
    count(distinct e.repo_id) as value
  from
    hdev_events_base_{{rnd}} e
  join
    hdev_repos_{{rnd}} r
  on
    r.repo_name = e.repo
  where
    (e.author_lower {{exclude_bots}})
  group by
    e.repo,
    e.author,
    e.company
  union all
  select
    'comments' as metric,
    c.repo,
    c.author,
    c.company,
    count(distinct c.id) as value
  from
    hdev_comments_base_{{rnd}} c
  join
    hdev_repos_{{rnd}} r
  on
    r.repo_name = c.repo
  where
    (c.author_lower {{exclude_bots}})
  group by
    c.repo,
    c.author,
    c.company
  union all
  select
    case i.is_pull_request
      when true then 'prs'
      else 'issues'
    end as metric,
    i.repo,
    i.author,
    i.company,
    count(distinct i.id) as value
  from
    hdev_issues_base_{{rnd}} i
  join
    hdev_repos_{{rnd}} r
  on
    r.repo_name = i.repo
  where
    (i.author_lower {{exclude_bots}})
  group by
    i.repo,
    i.is_pull_request,
    i.author,
    i.company
  union all
  select
    'merged_prs' as metric,
    pr.repo,
    pr.author,
    pr.company,
    count(distinct pr.id) as value
  from
    hdev_merged_prs_base_{{rnd}} pr
  join
    hdev_repos_{{rnd}} r
  on
    r.repo_name = pr.repo
  where
    (pr.author_lower {{exclude_bots}})
  group by
    pr.repo,
    pr.author,
    pr.company
  union all
  select
    'events' as metric,
    e.repo,
    e.author,
    e.company,
    count(distinct e.id) as value
  from
    hdev_events_base_{{rnd}} e
  join
    hdev_repos_{{rnd}} r
  on
    r.repo_name = e.repo
  where
    (e.author_lower {{exclude_bots}})
  group by
    e.repo,
    e.author,
    e.company
),
country_all_sub as (
  select
    'commits' as metric,
    a.country_name as country,
    a.login as author,
    c.company,
    count(distinct c.sha) as value
  from
    hdev_commits_data_{{rnd}} c
  join
    hdev_actors_country_{{rnd}} a
  on
    c.actor_id = a.id
  group by
    a.country_name,
    a.login,
    c.company
  union all
  select
    case e.type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    e.country,
    e.author,
    e.company,
    count(distinct e.id) as value
  from
    hdev_events_country_{{rnd}} e
  where
    e.type in (
      'PushEvent',
      'PullRequestReviewCommentEvent',
      'IssueCommentEvent',
      'CommitCommentEvent'
    )
    and (e.author_lower {{exclude_bots}})
  group by
    e.type,
    e.country,
    e.author,
    e.company
  union all
  select
    'contributions' as metric,
    e.country,
    e.author,
    e.company,
    count(distinct e.id) as value
  from
    hdev_events_country_{{rnd}} e
  where
    e.type in (
      'PushEvent',
      'PullRequestEvent',
      'IssuesEvent',
      'PullRequestReviewEvent',
      'CommitCommentEvent',
      'IssueCommentEvent',
      'PullRequestReviewCommentEvent'
    )
    and (e.author_lower {{exclude_bots}})
  group by
    e.country,
    e.author,
    e.company
  union all
  select
    'active_repos' as metric,
    e.country,
    e.author,
    e.company,
    count(distinct e.repo_id) as value
  from
    hdev_events_country_{{rnd}} e
  where
    (e.author_lower {{exclude_bots}})
  group by
    e.country,
    e.author,
    e.company
  union all
  select
    'comments' as metric,
    c.country,
    c.author,
    c.company,
    count(distinct c.id) as value
  from
    hdev_comments_country_{{rnd}} c
  where
    (c.author_lower {{exclude_bots}})
  group by
    c.country,
    c.author,
    c.company
  union all
  select
    case i.is_pull_request
      when true then 'prs'
      else 'issues'
    end as metric,
    i.country,
    i.author,
    i.company,
    count(distinct i.id) as value
  from
    hdev_issues_country_{{rnd}} i
  where
    (i.author_lower {{exclude_bots}})
  group by
    i.is_pull_request,
    i.country,
    i.author,
    i.company
  union all
  select
    'merged_prs' as metric,
    pr.country,
    pr.author,
    pr.company,
    count(distinct pr.id) as value
  from
    hdev_merged_prs_country_{{rnd}} pr
  where
    (pr.author_lower {{exclude_bots}})
  group by
    pr.country,
    pr.author,
    pr.company
  union all
  select
    'events' as metric,
    e.country,
    e.author,
    e.company,
    count(distinct e.id) as value
  from
    hdev_events_country_{{rnd}} e
  where
    (e.author_lower {{exclude_bots}})
  group by
    e.country,
    e.author,
    e.company
),
repo_country_sub as (
  select
    'commits' as metric,
    c.repo,
    a.country_name as country,
    a.login as author,
    c.company,
    count(distinct c.sha) as value
  from
    hdev_commits_data_{{rnd}} c
  join
    hdev_actors_country_{{rnd}} a
  on
    c.actor_id = a.id
  join
    hdev_repos_{{rnd}} r
  on
    r.repo_name = c.repo
  group by
    c.repo,
    a.country_name,
    a.login,
    c.company
  union all
  select
    case e.type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    e.repo,
    e.country,
    e.author,
    e.company,
    count(distinct e.id) as value
  from
    hdev_events_country_{{rnd}} e
  join
    hdev_repos_{{rnd}} r
  on
    r.repo_name = e.repo
  where
    e.type in (
      'PushEvent',
      'PullRequestReviewCommentEvent',
      'IssueCommentEvent',
      'CommitCommentEvent'
    )
    and (e.author_lower {{exclude_bots}})
  group by
    e.type,
    e.repo,
    e.country,
    e.author,
    e.company
  union all
  select
    'contributions' as metric,
    e.repo,
    e.country,
    e.author,
    e.company,
    count(distinct e.id) as value
  from
    hdev_events_country_{{rnd}} e
  join
    hdev_repos_{{rnd}} r
  on
    r.repo_name = e.repo
  where
    e.type in (
      'PushEvent',
      'PullRequestEvent',
      'IssuesEvent',
      'PullRequestReviewEvent',
      'CommitCommentEvent',
      'IssueCommentEvent',
      'PullRequestReviewCommentEvent'
    )
    and (e.author_lower {{exclude_bots}})
  group by
    e.repo,
    e.country,
    e.author,
    e.company
  union all
  select
    'active_repos' as metric,
    e.repo,
    e.country,
    e.author,
    e.company,
    count(distinct e.repo_id) as value
  from
    hdev_events_country_{{rnd}} e
  join
    hdev_repos_{{rnd}} r
  on
    r.repo_name = e.repo
  where
    (e.author_lower {{exclude_bots}})
  group by
    e.repo,
    e.country,
    e.author,
    e.company
  union all
  select
    'comments' as metric,
    c.repo,
    c.country,
    c.author,
    c.company,
    count(distinct c.id) as value
  from
    hdev_comments_country_{{rnd}} c
  join
    hdev_repos_{{rnd}} r
  on
    r.repo_name = c.repo
  where
    (c.author_lower {{exclude_bots}})
  group by
    c.repo,
    c.country,
    c.author,
    c.company
  union all
  select
    case i.is_pull_request
      when true then 'prs'
      else 'issues'
    end as metric,
    i.repo,
    i.country,
    i.author,
    i.company,
    count(distinct i.id) as value
  from
    hdev_issues_country_{{rnd}} i
  join
    hdev_repos_{{rnd}} r
  on
    r.repo_name = i.repo
  where
    (i.author_lower {{exclude_bots}})
  group by
    i.is_pull_request,
    i.repo,
    i.country,
    i.author,
    i.company
  union all
  select
    'merged_prs' as metric,
    pr.repo,
    pr.country,
    pr.author,
    pr.company,
    count(distinct pr.id) as value
  from
    hdev_merged_prs_country_{{rnd}} pr
  join
    hdev_repos_{{rnd}} r
  on
    r.repo_name = pr.repo
  where
    (pr.author_lower {{exclude_bots}})
  group by
    pr.repo,
    pr.country,
    pr.author,
    pr.company
  union all
  select
    'events' as metric,
    e.repo,
    e.country,
    e.author,
    e.company,
    count(distinct e.id) as value
  from
    hdev_events_country_{{rnd}} e
  join
    hdev_repos_{{rnd}} r
  on
    r.repo_name = e.repo
  where
    (e.event_author_lower {{exclude_bots}})
  group by
    e.repo,
    e.country,
    e.author,
    e.company
)
select
  'hdev_' || metric || ',All_All' as metric,
  author || '$$$' || company as name,
  value as value
from
  all_all_sub
where
  (metric = 'events' and value >= 200)
  or (metric = 'active_repos' and value >= 3)
  or (metric = 'contributions' and value >= 30)
  or (metric = 'commit_comments' and value >= 10)
  or (metric = 'comments' and value >= 20)
  or (metric = 'issue_comments' and value >= 20)
  or (metric = 'review_comments' and value >= 20)
  or (metric in ('commits','pushes','issues','prs','merged_prs') and value > 1)
union
select
  'hdev_' || metric || ',' || repo || '_All' as metric,
  author || '$$$' || company as name,
  value as value
from
  repo_sub
union
select
  'hdev_' || metric || ',All_' || country as metric,
  author || '$$$' || company as name,
  value as value
from
  country_all_sub
where
  (metric = 'events' and value >= 100)
  or (metric = 'active_repos' and value >= 3)
  or (metric = 'contributions' and value >= 15)
  or (metric = 'commit_comments' and value >= 5)
  or (metric = 'comments' and value >= 15)
  or (metric = 'issue_comments' and value >= 10)
  or (metric = 'review_comments' and value >= 10)
  or (metric in ('commits','pushes','issues','prs','merged_prs') and value > 1)
union
select
  'hdev_' || metric || ',' || repo || '_' || country as metric,
  author || '$$$' || company as name,
  value as value
from
  repo_country_sub
where
  (metric = 'events' and value >= 20)
  or (metric = 'active_repos' and value >= 2)
  or (metric = 'contributions' and value >= 5)
  or (metric = 'commit_comments' and value >= 3)
  or (metric = 'comments' and value >= 5)
  or (metric = 'issue_comments' and value >= 5)
  or (metric = 'review_comments' and value >= 5)
  or (metric in ('commits','pushes','issues','prs','merged_prs'))
order by
  metric asc,
  value desc,
  name asc
;

