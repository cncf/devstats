create temp table hdev_repos_{{rnd}} as
select
  id,
  name,
  repo_group
from
  gha_repos
where
  repo_group in (select repo_group_name from trepo_groups)
;
create index on hdev_repos_{{rnd}} (id, name);
analyze hdev_repos_{{rnd}};

create temp table hdev_event_ids_{{rnd}} as
select distinct
  c.event_id
from
  gha_commits c
join
  hdev_repos_{{rnd}} r
on
  c.dup_repo_id = r.id
  and c.dup_repo_name = r.name
where
  c.event_id is not null
  and {{period:c.dup_created_at}}
union
select distinct
  e.id as event_id
from
  gha_events e
join
  hdev_repos_{{rnd}} r
on
  e.repo_id = r.id
  and e.dup_repo_name = r.name
where
  {{period:e.created_at}}
union
select distinct
  c.event_id
from
  gha_comments c
join
  hdev_repos_{{rnd}} r
on
  c.dup_repo_id = r.id
  and c.dup_repo_name = r.name
where
  c.event_id is not null
  and {{period:c.created_at}}
union
select distinct
  i.event_id
from
  gha_issues i
join
  hdev_repos_{{rnd}} r
on
  i.dup_repo_id = r.id
  and i.dup_repo_name = r.name
where
  i.event_id is not null
  and {{period:i.created_at}}
union
select distinct
  pr.event_id
from
  gha_pull_requests pr
join
  hdev_repos_{{rnd}} r
on
  pr.dup_repo_id = r.id
  and pr.dup_repo_name = r.name
where
  pr.event_id is not null
  and pr.merged_at is not null
  and {{period:pr.merged_at}}
;
create index on hdev_event_ids_{{rnd}} (event_id);
analyze hdev_event_ids_{{rnd}};

create temp table hdev_ecf_rg_{{rnd}} as
select distinct
  ecf.event_id,
  ecf.repo_group
from
  gha_events_commits_files ecf
join
  hdev_event_ids_{{rnd}} ids
on
  ids.event_id = ecf.event_id
;
create index on hdev_ecf_rg_{{rnd}} (event_id);
analyze hdev_ecf_rg_{{rnd}};

create temp table hdev_commits_data_{{rnd}} as
select
  x.repo_group,
  x.sha,
  x.actor_id,
  x.actor_login,
  x.company
from (
  select
    coalesce(ecf.repo_group, r.repo_group) as repo_group,
    c.sha,
    v.actor_id,
    v.actor_login,
    coalesce(aa.company_name, '') as company
  from
    hdev_repos_{{rnd}} r
  join
    gha_commits c
  on
    c.dup_repo_id = r.id
    and c.dup_repo_name = r.name
  left join
    hdev_ecf_rg_{{rnd}} ecf
  on
    ecf.event_id = c.event_id
  cross join lateral
    (values
      ('actor', c.dup_actor_id, c.dup_actor_login),
      ('author', c.author_id, c.dup_author_login),
      ('committer', c.committer_id, c.dup_committer_login)
    ) v(role, actor_id, actor_login)
  left join
    gha_actors_affiliations aa
  on
    aa.actor_id = v.actor_id
    and aa.dt_from <= c.dup_created_at
    and aa.dt_to > c.dup_created_at
  where
    {{period:c.dup_created_at}}
    and (v.role = 'actor' or v.actor_id is not null)
    and (lower(v.actor_login) {{exclude_bots}})
  union all
  select
    r.repo_group as repo_group,
    cr.sha,
    cr.actor_id,
    lower(cr.actor_login) as actor_login,
    coalesce(aa.company_name, '') as company
  from
    hdev_repos_{{rnd}} r
  join
    gha_commits_roles cr
  on
    cr.dup_repo_id = r.id
    and cr.dup_repo_name = r.name
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
) x
group by
  x.repo_group,
  x.sha,
  x.actor_id,
  x.actor_login,
  x.company
;
create index on hdev_commits_data_{{rnd}} (repo_group);
create index on hdev_commits_data_{{rnd}} (actor_id);
create index on hdev_commits_data_{{rnd}} (actor_login);
analyze hdev_commits_data_{{rnd}};

create temp table hdev_events_base_{{rnd}} as
select
  e.id,
  e.type,
  e.repo_id,
  e.dup_repo_name,
  e.actor_id,
  e.dup_actor_login,
  lower(e.dup_actor_login) as dup_actor_login_lower,
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
create index on hdev_events_base_{{rnd}} (id);
create index on hdev_events_base_{{rnd}} (repo_id, dup_repo_name);
create index on hdev_events_base_{{rnd}} (actor_id);
create index on hdev_events_base_{{rnd}} (dup_actor_login);
analyze hdev_events_base_{{rnd}};

create temp table hdev_events_rg_{{rnd}} as
select
  coalesce(ecf.repo_group, r.repo_group) as repo_group,
  e.id,
  e.type,
  e.repo_id,
  e.actor_id,
  e.dup_actor_login,
  e.dup_actor_login_lower,
  e.company
from
  hdev_events_base_{{rnd}} e
join
  hdev_repos_{{rnd}} r
on
  r.id = e.repo_id
  and r.name = e.dup_repo_name
left join
  hdev_ecf_rg_{{rnd}} ecf
on
  ecf.event_id = e.id
;
create index on hdev_events_rg_{{rnd}} (repo_group);
create index on hdev_events_rg_{{rnd}} (actor_id);
create index on hdev_events_rg_{{rnd}} (dup_actor_login);
analyze hdev_events_rg_{{rnd}};

create temp table hdev_comments_base_{{rnd}} as
select
  c.id,
  c.event_id,
  c.dup_repo_id,
  c.dup_repo_name,
  c.user_id,
  c.dup_user_login,
  lower(c.dup_user_login) as dup_user_login_lower,
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
create index on hdev_comments_base_{{rnd}} (dup_repo_id, dup_repo_name);
create index on hdev_comments_base_{{rnd}} (event_id);
create index on hdev_comments_base_{{rnd}} (user_id);
create index on hdev_comments_base_{{rnd}} (dup_user_login);
analyze hdev_comments_base_{{rnd}};

create temp table hdev_comments_rg_{{rnd}} as
select
  coalesce(ecf.repo_group, r.repo_group) as repo_group,
  c.id,
  c.user_id,
  c.dup_user_login,
  c.dup_user_login_lower,
  c.company
from
  hdev_comments_base_{{rnd}} c
join
  hdev_repos_{{rnd}} r
on
  r.id = c.dup_repo_id
  and r.name = c.dup_repo_name
left join
  hdev_ecf_rg_{{rnd}} ecf
on
  ecf.event_id = c.event_id
;
create index on hdev_comments_rg_{{rnd}} (repo_group);
create index on hdev_comments_rg_{{rnd}} (user_id);
create index on hdev_comments_rg_{{rnd}} (dup_user_login);
analyze hdev_comments_rg_{{rnd}};

create temp table hdev_issues_base_{{rnd}} as
select
  i.id,
  i.event_id,
  i.dup_repo_id,
  i.dup_repo_name,
  i.user_id,
  i.dup_user_login,
  lower(i.dup_user_login) as dup_user_login_lower,
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
create index on hdev_issues_base_{{rnd}} (dup_repo_id, dup_repo_name);
create index on hdev_issues_base_{{rnd}} (event_id);
create index on hdev_issues_base_{{rnd}} (user_id);
create index on hdev_issues_base_{{rnd}} (dup_user_login);
create index on hdev_issues_base_{{rnd}} (is_pull_request);
analyze hdev_issues_base_{{rnd}};

create temp table hdev_issues_rg_{{rnd}} as
select
  coalesce(ecf.repo_group, r.repo_group) as repo_group,
  i.id,
  i.user_id,
  i.dup_user_login,
  i.dup_user_login_lower,
  i.is_pull_request,
  i.company
from
  hdev_issues_base_{{rnd}} i
join
  hdev_repos_{{rnd}} r
on
  r.id = i.dup_repo_id
  and r.name = i.dup_repo_name
left join
  hdev_ecf_rg_{{rnd}} ecf
on
  ecf.event_id = i.event_id
;
create index on hdev_issues_rg_{{rnd}} (repo_group);
create index on hdev_issues_rg_{{rnd}} (user_id);
create index on hdev_issues_rg_{{rnd}} (dup_user_login);
analyze hdev_issues_rg_{{rnd}};

create temp table hdev_merged_prs_base_{{rnd}} as
select
  pr.id,
  pr.event_id,
  pr.dup_repo_id,
  pr.dup_repo_name,
  pr.user_id,
  pr.dup_user_login,
  lower(pr.dup_user_login) as dup_user_login_lower,
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
create index on hdev_merged_prs_base_{{rnd}} (dup_repo_id, dup_repo_name);
create index on hdev_merged_prs_base_{{rnd}} (event_id);
create index on hdev_merged_prs_base_{{rnd}} (user_id);
create index on hdev_merged_prs_base_{{rnd}} (dup_user_login);
analyze hdev_merged_prs_base_{{rnd}};

create temp table hdev_merged_prs_rg_{{rnd}} as
select
  coalesce(ecf.repo_group, r.repo_group) as repo_group,
  pr.id,
  pr.user_id,
  pr.dup_user_login,
  pr.dup_user_login_lower,
  pr.company
from
  hdev_merged_prs_base_{{rnd}} pr
join
  hdev_repos_{{rnd}} r
on
  r.id = pr.dup_repo_id
  and r.name = pr.dup_repo_name
left join
  hdev_ecf_rg_{{rnd}} ecf
on
  ecf.event_id = pr.event_id
;
create index on hdev_merged_prs_rg_{{rnd}} (repo_group);
create index on hdev_merged_prs_rg_{{rnd}} (user_id);
create index on hdev_merged_prs_rg_{{rnd}} (dup_user_login);
analyze hdev_merged_prs_rg_{{rnd}};

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
  e.repo_id,
  e.dup_repo_name,
  e.actor_id,
  e.dup_actor_login,
  e.dup_actor_login_lower,
  a.country_name as country,
  a.login as author,
  e.company
from
  hdev_events_base_{{rnd}} e
join
  hdev_actors_country_{{rnd}} a
on
  a.id = e.actor_id
union all
select
  e.id,
  e.type,
  e.repo_id,
  e.dup_repo_name,
  e.actor_id,
  e.dup_actor_login,
  e.dup_actor_login_lower,
  a.country_name as country,
  a.login as author,
  e.company
from
  hdev_events_base_{{rnd}} e
join
  hdev_actors_country_{{rnd}} a
on
  a.login = e.dup_actor_login
where
  e.actor_id is null
  or e.actor_id <> a.id
;
create index on hdev_events_country_{{rnd}} (country);
create index on hdev_events_country_{{rnd}} (author);
create index on hdev_events_country_{{rnd}} (repo_id, dup_repo_name);
analyze hdev_events_country_{{rnd}};

create temp table hdev_comments_country_{{rnd}} as
select
  c.id,
  c.event_id,
  c.dup_repo_id,
  c.dup_repo_name,
  c.user_id,
  c.dup_user_login,
  c.dup_user_login_lower,
  a.country_name as country,
  a.login as author,
  c.company
from
  hdev_comments_base_{{rnd}} c
join
  hdev_actors_country_{{rnd}} a
on
  a.id = c.user_id
union all
select
  c.id,
  c.event_id,
  c.dup_repo_id,
  c.dup_repo_name,
  c.user_id,
  c.dup_user_login,
  c.dup_user_login_lower,
  a.country_name as country,
  a.login as author,
  c.company
from
  hdev_comments_base_{{rnd}} c
join
  hdev_actors_country_{{rnd}} a
on
  a.login = c.dup_user_login
where
  c.user_id is null
  or c.user_id <> a.id
;
create index on hdev_comments_country_{{rnd}} (country);
create index on hdev_comments_country_{{rnd}} (author);
create index on hdev_comments_country_{{rnd}} (dup_repo_id, dup_repo_name);
analyze hdev_comments_country_{{rnd}};

create temp table hdev_issues_country_{{rnd}} as
select
  i.id,
  i.event_id,
  i.dup_repo_id,
  i.dup_repo_name,
  i.user_id,
  i.dup_user_login,
  i.dup_user_login_lower,
  i.is_pull_request,
  a.country_name as country,
  a.login as author,
  i.company
from
  hdev_issues_base_{{rnd}} i
join
  hdev_actors_country_{{rnd}} a
on
  a.id = i.user_id
union all
select
  i.id,
  i.event_id,
  i.dup_repo_id,
  i.dup_repo_name,
  i.user_id,
  i.dup_user_login,
  i.dup_user_login_lower,
  i.is_pull_request,
  a.country_name as country,
  a.login as author,
  i.company
from
  hdev_issues_base_{{rnd}} i
join
  hdev_actors_country_{{rnd}} a
on
  a.login = i.dup_user_login
where
  i.user_id is null
  or i.user_id <> a.id
;
create index on hdev_issues_country_{{rnd}} (country);
create index on hdev_issues_country_{{rnd}} (author);
create index on hdev_issues_country_{{rnd}} (dup_repo_id, dup_repo_name);
analyze hdev_issues_country_{{rnd}};

create temp table hdev_merged_prs_country_{{rnd}} as
select
  pr.id,
  pr.event_id,
  pr.dup_repo_id,
  pr.dup_repo_name,
  pr.user_id,
  pr.dup_user_login,
  pr.dup_user_login_lower,
  a.country_name as country,
  a.login as author,
  pr.company
from
  hdev_merged_prs_base_{{rnd}} pr
join
  hdev_actors_country_{{rnd}} a
on
  a.id = pr.user_id
union all
select
  pr.id,
  pr.event_id,
  pr.dup_repo_id,
  pr.dup_repo_name,
  pr.user_id,
  pr.dup_user_login,
  pr.dup_user_login_lower,
  a.country_name as country,
  a.login as author,
  pr.company
from
  hdev_merged_prs_base_{{rnd}} pr
join
  hdev_actors_country_{{rnd}} a
on
  a.login = pr.dup_user_login
where
  pr.user_id is null
  or pr.user_id <> a.id
;
create index on hdev_merged_prs_country_{{rnd}} (country);
create index on hdev_merged_prs_country_{{rnd}} (author);
create index on hdev_merged_prs_country_{{rnd}} (dup_repo_id, dup_repo_name);
analyze hdev_merged_prs_country_{{rnd}};

create temp table hdev_events_rg_country_{{rnd}} as
select
  coalesce(ecf.repo_group, r.repo_group) as repo_group,
  e.id,
  e.type,
  e.repo_id,
  e.dup_actor_login,
  e.dup_actor_login_lower,
  e.actor_id,
  e.country,
  e.author,
  e.company
from
  hdev_events_country_{{rnd}} e
join
  hdev_repos_{{rnd}} r
on
  r.id = e.repo_id
  and r.name = e.dup_repo_name
left join
  hdev_ecf_rg_{{rnd}} ecf
on
  ecf.event_id = e.id
;
create index on hdev_events_rg_country_{{rnd}} (repo_group);
create index on hdev_events_rg_country_{{rnd}} (country);
create index on hdev_events_rg_country_{{rnd}} (author);
analyze hdev_events_rg_country_{{rnd}};

create temp table hdev_comments_rg_country_{{rnd}} as
select
  coalesce(ecf.repo_group, r.repo_group) as repo_group,
  c.id,
  c.country,
  c.author,
  c.company
from
  hdev_comments_country_{{rnd}} c
join
  hdev_repos_{{rnd}} r
on
  r.id = c.dup_repo_id
  and r.name = c.dup_repo_name
left join
  hdev_ecf_rg_{{rnd}} ecf
on
  ecf.event_id = c.event_id
;
create index on hdev_comments_rg_country_{{rnd}} (repo_group);
create index on hdev_comments_rg_country_{{rnd}} (country);
create index on hdev_comments_rg_country_{{rnd}} (author);
analyze hdev_comments_rg_country_{{rnd}};

create temp table hdev_issues_rg_country_{{rnd}} as
select
  coalesce(ecf.repo_group, r.repo_group) as repo_group,
  i.id,
  i.is_pull_request,
  i.country,
  i.author,
  i.company
from
  hdev_issues_country_{{rnd}} i
join
  hdev_repos_{{rnd}} r
on
  r.id = i.dup_repo_id
  and r.name = i.dup_repo_name
left join
  hdev_ecf_rg_{{rnd}} ecf
on
  ecf.event_id = i.event_id
;
create index on hdev_issues_rg_country_{{rnd}} (repo_group);
create index on hdev_issues_rg_country_{{rnd}} (country);
create index on hdev_issues_rg_country_{{rnd}} (author);
analyze hdev_issues_rg_country_{{rnd}};

create temp table hdev_merged_prs_rg_country_{{rnd}} as
select
  coalesce(ecf.repo_group, r.repo_group) as repo_group,
  pr.id,
  pr.country,
  pr.author,
  pr.company
from
  hdev_merged_prs_country_{{rnd}} pr
join
  hdev_repos_{{rnd}} r
on
  r.id = pr.dup_repo_id
  and r.name = pr.dup_repo_name
left join
  hdev_ecf_rg_{{rnd}} ecf
on
  ecf.event_id = pr.event_id
;
create index on hdev_merged_prs_rg_country_{{rnd}} (repo_group);
create index on hdev_merged_prs_rg_country_{{rnd}} (country);
create index on hdev_merged_prs_rg_country_{{rnd}} (author);
analyze hdev_merged_prs_rg_country_{{rnd}};

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
      when 'PullRequestReviewEvent' then 'raw_reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    dup_actor_login as author,
    company,
    count(id) as value
  from
    hdev_events_base_{{rnd}}
  where
    type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and (dup_actor_login_lower {{exclude_bots}})
  group by
    type,
    dup_actor_login,
    company
  union all
  select
    'contributions' as metric,
    dup_actor_login as author,
    company,
    count(id) as value
  from
    hdev_events_base_{{rnd}}
  where
    type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
    and (dup_actor_login_lower {{exclude_bots}})
  group by
    dup_actor_login,
    company
  union all
  select
    'active_repos' as metric,
    dup_actor_login as author,
    company,
    count(distinct repo_id) as value
  from
    hdev_events_base_{{rnd}}
  where
    (dup_actor_login_lower {{exclude_bots}})
  group by
    dup_actor_login,
    company
  union all
  select
    'comments' as metric,
    dup_user_login as author,
    company,
    count(distinct id) as value
  from
    hdev_comments_base_{{rnd}}
  where
    (dup_user_login_lower {{exclude_bots}})
  group by
    dup_user_login,
    company
  union all
  select
    'issues' as metric,
    dup_user_login as author,
    company,
    count(distinct id) as value
  from
    hdev_issues_base_{{rnd}}
  where
    is_pull_request = false
    and (dup_user_login_lower {{exclude_bots}})
  group by
    dup_user_login,
    company
  union all
  select
    'prs' as metric,
    dup_user_login as author,
    company,
    count(distinct id) as value
  from
    hdev_issues_base_{{rnd}}
  where
    is_pull_request = true
    and (dup_user_login_lower {{exclude_bots}})
  group by
    dup_user_login,
    company
  union all
  select
    'merged_prs' as metric,
    dup_user_login as author,
    company,
    count(distinct id) as value
  from
    hdev_merged_prs_base_{{rnd}}
  where
    (dup_user_login_lower {{exclude_bots}})
  group by
    dup_user_login,
    company
  union all
  select
    'events' as metric,
    dup_actor_login as author,
    company,
    count(id) as value
  from
    hdev_events_base_{{rnd}}
  where
    (dup_actor_login_lower {{exclude_bots}})
  group by
    dup_actor_login,
    company
),
rg_sub as (
  select
    'commits' as metric,
    repo_group,
    actor_login as author,
    company,
    count(distinct sha) as value
  from
    hdev_commits_data_{{rnd}}
  where
    repo_group is not null
  group by
    repo_group,
    actor_login,
    company
  union all
  select
    case type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'raw_reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    repo_group,
    dup_actor_login as author,
    company,
    count(distinct id) as value
  from
    hdev_events_rg_{{rnd}}
  where
    repo_group is not null
    and type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and (dup_actor_login_lower {{exclude_bots}})
  group by
    repo_group,
    type,
    dup_actor_login,
    company
  union all
  select
    'contributions' as metric,
    repo_group,
    dup_actor_login as author,
    company,
    count(distinct id) as value
  from
    hdev_events_rg_{{rnd}}
  where
    repo_group is not null
    and type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
    and (dup_actor_login_lower {{exclude_bots}})
  group by
    repo_group,
    dup_actor_login,
    company
  union all
  select
    'active_repos' as metric,
    repo_group,
    dup_actor_login as author,
    company,
    count(distinct repo_id) as value
  from
    hdev_events_rg_{{rnd}}
  where
    repo_group is not null
    and (dup_actor_login_lower {{exclude_bots}})
  group by
    repo_group,
    dup_actor_login,
    company
  union all
  select
    'comments' as metric,
    repo_group,
    dup_user_login as author,
    company,
    count(distinct id) as value
  from
    hdev_comments_rg_{{rnd}}
  where
    repo_group is not null
    and (dup_user_login_lower {{exclude_bots}})
  group by
    repo_group,
    dup_user_login,
    company
  union all
  select
    case is_pull_request when true then 'prs' else 'issues' end as metric,
    repo_group,
    dup_user_login as author,
    company,
    count(distinct id) as value
  from
    hdev_issues_rg_{{rnd}}
  where
    repo_group is not null
    and (dup_user_login_lower {{exclude_bots}})
  group by
    repo_group,
    is_pull_request,
    dup_user_login,
    company
  union all
  select
    'merged_prs' as metric,
    repo_group,
    dup_user_login as author,
    company,
    count(distinct id) as value
  from
    hdev_merged_prs_rg_{{rnd}}
  where
    repo_group is not null
    and (dup_user_login_lower {{exclude_bots}})
  group by
    repo_group,
    dup_user_login,
    company
  union all
  select
    'events' as metric,
    repo_group,
    dup_actor_login as author,
    company,
    count(distinct id) as value
  from
    hdev_events_rg_{{rnd}}
  where
    repo_group is not null
    and (dup_actor_login_lower {{exclude_bots}})
  group by
    repo_group,
    dup_actor_login,
    company
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
    case type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'raw_reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    country,
    author,
    company,
    count(distinct id) as value
  from
    hdev_events_country_{{rnd}}
  where
    type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and (lower(author) {{exclude_bots}})
  group by
    type,
    country,
    author,
    company
  union all
  select
    'contributions' as metric,
    country,
    author,
    company,
    count(distinct id) as value
  from
    hdev_events_country_{{rnd}}
  where
    type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
    and (lower(author) {{exclude_bots}})
  group by
    country,
    author,
    company
  union all
  select
    'active_repos' as metric,
    country,
    author,
    company,
    count(distinct repo_id) as value
  from
    hdev_events_country_{{rnd}}
  where
    (lower(author) {{exclude_bots}})
  group by
    country,
    author,
    company
  union all
  select
    'comments' as metric,
    country,
    author,
    company,
    count(distinct id) as value
  from
    hdev_comments_country_{{rnd}}
  where
    (lower(author) {{exclude_bots}})
  group by
    country,
    author,
    company
  union all
  select
    'issues' as metric,
    country,
    author,
    company,
    count(distinct id) as value
  from
    hdev_issues_country_{{rnd}}
  where
    is_pull_request = false
    and (lower(author) {{exclude_bots}})
  group by
    country,
    author,
    company
  union all
  select
    'prs' as metric,
    country,
    author,
    company,
    count(distinct id) as value
  from
    hdev_issues_country_{{rnd}}
  where
    is_pull_request = true
    and (lower(author) {{exclude_bots}})
  group by
    country,
    author,
    company
  union all
  select
    'merged_prs' as metric,
    country,
    author,
    company,
    count(distinct id) as value
  from
    hdev_merged_prs_country_{{rnd}}
  where
    (lower(author) {{exclude_bots}})
  group by
    country,
    author,
    company
  union all
  select
    'events' as metric,
    country,
    author,
    company,
    count(distinct id) as value
  from
    hdev_events_country_{{rnd}}
  where
    (lower(author) {{exclude_bots}})
  group by
    country,
    author,
    company
),
rg_country_sub as (
  select
    'commits' as metric,
    c.repo_group,
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
  where
    c.repo_group is not null
  group by
    c.repo_group,
    a.country_name,
    a.login,
    c.company
  union all
  select
    case type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'raw_reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    repo_group,
    country,
    author,
    company,
    count(distinct id) as value
  from
    hdev_events_rg_country_{{rnd}}
  where
    repo_group is not null
    and type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and (lower(author) {{exclude_bots}})
  group by
    repo_group,
    type,
    country,
    author,
    company
  union all
  select
    'contributions' as metric,
    repo_group,
    country,
    author,
    company,
    count(distinct id) as value
  from
    hdev_events_rg_country_{{rnd}}
  where
    repo_group is not null
    and type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
    and (lower(author) {{exclude_bots}})
  group by
    repo_group,
    country,
    author,
    company
  union all
  select
    'active_repos' as metric,
    repo_group,
    country,
    author,
    company,
    count(distinct repo_id) as value
  from
    hdev_events_rg_country_{{rnd}}
  where
    repo_group is not null
    and (lower(author) {{exclude_bots}})
  group by
    repo_group,
    country,
    author,
    company
  union all
  select
    'comments' as metric,
    repo_group,
    country,
    author,
    company,
    count(distinct id) as value
  from
    hdev_comments_rg_country_{{rnd}}
  where
    repo_group is not null
    and (lower(author) {{exclude_bots}})
  group by
    repo_group,
    country,
    author,
    company
  union all
  select
    case is_pull_request when true then 'prs' else 'issues' end as metric,
    repo_group,
    country,
    author,
    company,
    count(distinct id) as value
  from
    hdev_issues_rg_country_{{rnd}}
  where
    repo_group is not null
    and (lower(author) {{exclude_bots}})
  group by
    repo_group,
    is_pull_request,
    country,
    author,
    company
  union all
  select
    'merged_prs' as metric,
    repo_group,
    country,
    author,
    company,
    count(distinct id) as value
  from
    hdev_merged_prs_rg_country_{{rnd}}
  where
    repo_group is not null
    and (lower(author) {{exclude_bots}})
  group by
    repo_group,
    country,
    author,
    company
  union all
  select
    'events' as metric,
    repo_group,
    country,
    author,
    company,
    count(distinct id) as value
  from
    hdev_events_rg_country_{{rnd}}
  where
    repo_group is not null
    and (dup_actor_login_lower {{exclude_bots}})
  group by
    repo_group,
    country,
    author,
    company
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
  or (metric = 'raw_reviews' and value >= 15)
  or (metric = 'issue_comments' and value >= 20)
  or (metric = 'review_comments' and value >= 20)
  or (metric in ('commits','pushes','issues','prs','merged_prs') and value > 1)
union
select
  'hdev_' || metric || ',' || repo_group || '_All' as metric,
  author || '$$$' || company as name,
  value as value
from
  rg_sub
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
  or (metric = 'raw_reviews' and value >= 10)
  or (metric = 'issue_comments' and value >= 10)
  or (metric = 'review_comments' and value >= 10)
  or (metric in ('commits','pushes','issues','prs','merged_prs') and value > 1)
union
select
  'hdev_' || metric || ',' || repo_group || '_' || country as metric,
  author || '$$$' || company as name,
  value as value
from
  rg_country_sub
where
  (metric = 'events' and value >= 20)
  or (metric = 'active_repos' and value >= 2)
  or (metric = 'contributions' and value >= 5)
  or (metric = 'commit_comments' and value >= 3)
  or (metric = 'comments' and value >= 5)
  or (metric = 'raw_reviews' and value >= 3)
  or (metric = 'issue_comments' and value >= 5)
  or (metric = 'review_comments' and value >= 5)
  or (metric in ('commits','pushes','issues','prs','merged_prs'))
order by
  metric asc,
  value desc,
  name asc
;

