create temp table hdev_repo_groups_{{rnd}} as
select
  id,
  name,
  repo_group
from
  gha_repo_groups
where
  repo_group in (select repo_group_name from trepo_groups)
;
create index on hdev_repo_groups_{{rnd}} (id, name);
analyze hdev_repo_groups_{{rnd}};

create temp table hdev_commits_data_{{rnd}} as
select
  r.repo_group,
  c.sha,
  v.actor_id as actor_id,
  lower(v.actor_login) as actor_login,
  coalesce(aa.company_name, '') as company
from
  hdev_repo_groups_{{rnd}} r
join
  gha_commits c
on
  c.dup_repo_id = r.id
  and c.dup_repo_name = r.name
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
  r.repo_group,
  cr.sha,
  cr.actor_id as actor_id,
  lower(cr.actor_login) as actor_login,
  coalesce(aa.company_name, '') as company
from
  hdev_repo_groups_{{rnd}} r
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
;
create index on hdev_commits_data_{{rnd}} (repo_group);
create index on hdev_commits_data_{{rnd}} (actor_id);
analyze hdev_commits_data_{{rnd}};

create temp table hdev_events_{{rnd}} as
select
  e.id,
  e.type,
  e.repo_id,
  rg.repo_group,
  e.actor_id,
  e.dup_actor_login,
  lower(e.dup_actor_login) as dup_actor_login_lower,
  aa.company_name as company_name
from
  gha_events e
left join
  hdev_repo_groups_{{rnd}} rg
on
  rg.id = e.repo_id
  and rg.name = e.dup_repo_name
left join
  gha_actors_affiliations aa
on
  aa.actor_id = e.actor_id
  and aa.dt_from <= e.created_at
  and aa.dt_to > e.created_at
where
  {{period:e.created_at}}
;
create index on hdev_events_{{rnd}} (actor_id);
create index on hdev_events_{{rnd}} (dup_actor_login);
create index on hdev_events_{{rnd}} (repo_group);
create index on hdev_events_{{rnd}} (type);
analyze hdev_events_{{rnd}};

create temp table hdev_comments_{{rnd}} as
select
  c.id,
  rg.repo_group,
  c.user_id as actor_id,
  c.dup_user_login,
  lower(c.dup_user_login) as dup_user_login_lower,
  aa.company_name as company_name
from
  gha_comments c
left join
  hdev_repo_groups_{{rnd}} rg
on
  rg.id = c.dup_repo_id
  and rg.name = c.dup_repo_name
left join
  gha_actors_affiliations aa
on
  aa.actor_id = c.user_id
  and aa.dt_from <= c.created_at
  and aa.dt_to > c.created_at
where
  {{period:c.created_at}}
;
create index on hdev_comments_{{rnd}} (actor_id);
create index on hdev_comments_{{rnd}} (dup_user_login);
create index on hdev_comments_{{rnd}} (repo_group);
analyze hdev_comments_{{rnd}};

create temp table hdev_issues_{{rnd}} as
select
  i.id,
  rg.repo_group,
  i.is_pull_request,
  i.user_id as actor_id,
  i.dup_user_login,
  lower(i.dup_user_login) as dup_user_login_lower,
  aa.company_name as company_name
from
  gha_issues i
left join
  hdev_repo_groups_{{rnd}} rg
on
  rg.id = i.dup_repo_id
  and rg.name = i.dup_repo_name
left join
  gha_actors_affiliations aa
on
  aa.actor_id = i.user_id
  and aa.dt_from <= i.created_at
  and aa.dt_to > i.created_at
where
  {{period:i.created_at}}
;
create index on hdev_issues_{{rnd}} (actor_id);
create index on hdev_issues_{{rnd}} (dup_user_login);
create index on hdev_issues_{{rnd}} (repo_group);
create index on hdev_issues_{{rnd}} (is_pull_request);
analyze hdev_issues_{{rnd}};

create temp table hdev_merged_prs_{{rnd}} as
select
  pr.id,
  rg.repo_group,
  pr.user_id as actor_id,
  pr.dup_user_login,
  lower(pr.dup_user_login) as dup_user_login_lower,
  aa.company_name as company_name
from
  gha_pull_requests pr
left join
  hdev_repo_groups_{{rnd}} rg
on
  rg.id = pr.dup_repo_id
  and rg.name = pr.dup_repo_name
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
create index on hdev_merged_prs_{{rnd}} (actor_id);
create index on hdev_merged_prs_{{rnd}} (dup_user_login);
create index on hdev_merged_prs_{{rnd}} (repo_group);
analyze hdev_merged_prs_{{rnd}};

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
  e.repo_id,
  e.repo_group,
  e.type,
  e.dup_actor_login_lower as src_login_lower,
  a.country_name as country,
  a.login_lower as author,
  e.company_name as company_name
from
  hdev_events_{{rnd}} e
join
  hdev_actors_country_{{rnd}} a
on
  a.id = e.actor_id
union all
select
  e.id,
  e.repo_id,
  e.repo_group,
  e.type,
  e.dup_actor_login_lower as src_login_lower,
  a.country_name as country,
  a.login_lower as author,
  e.company_name as company_name
from
  hdev_events_{{rnd}} e
join
  hdev_actors_country_{{rnd}} a
on
  a.login = e.dup_actor_login
where
  e.actor_id is null
  or a.id <> e.actor_id
;
create index on hdev_events_country_{{rnd}} (repo_group);
create index on hdev_events_country_{{rnd}} (country);
analyze hdev_events_country_{{rnd}};

create temp table hdev_comments_country_{{rnd}} as
select
  c.id,
  c.repo_group,
  c.dup_user_login_lower as src_login_lower,
  a.country_name as country,
  a.login_lower as author,
  c.company_name as company_name
from
  hdev_comments_{{rnd}} c
join
  hdev_actors_country_{{rnd}} a
on
  a.id = c.actor_id
union all
select
  c.id,
  c.repo_group,
  c.dup_user_login_lower as src_login_lower,
  a.country_name as country,
  a.login_lower as author,
  c.company_name as company_name
from
  hdev_comments_{{rnd}} c
join
  hdev_actors_country_{{rnd}} a
on
  a.login = c.dup_user_login
where
  c.actor_id is null
  or a.id <> c.actor_id
;
create index on hdev_comments_country_{{rnd}} (repo_group);
create index on hdev_comments_country_{{rnd}} (country);
analyze hdev_comments_country_{{rnd}};

create temp table hdev_issues_country_{{rnd}} as
select
  i.id,
  i.repo_group,
  i.is_pull_request,
  i.dup_user_login_lower as src_login_lower,
  a.country_name as country,
  a.login_lower as author,
  i.company_name as company_name
from
  hdev_issues_{{rnd}} i
join
  hdev_actors_country_{{rnd}} a
on
  a.id = i.actor_id
union all
select
  i.id,
  i.repo_group,
  i.is_pull_request,
  i.dup_user_login_lower as src_login_lower,
  a.country_name as country,
  a.login_lower as author,
  i.company_name as company_name
from
  hdev_issues_{{rnd}} i
join
  hdev_actors_country_{{rnd}} a
on
  a.login = i.dup_user_login
where
  i.actor_id is null
  or a.id <> i.actor_id
;
create index on hdev_issues_country_{{rnd}} (repo_group);
create index on hdev_issues_country_{{rnd}} (country);
analyze hdev_issues_country_{{rnd}};

create temp table hdev_merged_prs_country_{{rnd}} as
select
  pr.id,
  pr.repo_group,
  pr.dup_user_login_lower as src_login_lower,
  a.country_name as country,
  a.login_lower as author,
  pr.company_name as company_name
from
  hdev_merged_prs_{{rnd}} pr
join
  hdev_actors_country_{{rnd}} a
on
  a.id = pr.actor_id
union all
select
  pr.id,
  pr.repo_group,
  pr.dup_user_login_lower as src_login_lower,
  a.country_name as country,
  a.login_lower as author,
  pr.company_name as company_name
from
  hdev_merged_prs_{{rnd}} pr
join
  hdev_actors_country_{{rnd}} a
on
  a.login = pr.dup_user_login
where
  pr.actor_id is null
  or a.id <> pr.actor_id
;
create index on hdev_merged_prs_country_{{rnd}} (repo_group);
create index on hdev_merged_prs_country_{{rnd}} (country);
analyze hdev_merged_prs_country_{{rnd}};

with
events_type_all as (
  select
    case type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    dup_actor_login_lower as author,
    coalesce(company_name, '') as company,
    count(id) as value
  from
    hdev_events_{{rnd}}
  where
    type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and (dup_actor_login_lower {{exclude_bots}})
  group by
    type,
    dup_actor_login_lower,
    company_name
), events_overall_all as (
  select
    dup_actor_login_lower as author,
    company_name,
    count(id) as events_value,
    count(distinct repo_id) as active_repos_value,
    count(distinct id) filter (
      where type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
    ) as contributions_value
  from
    hdev_events_{{rnd}}
  where
    (dup_actor_login_lower {{exclude_bots}})
  group by
    dup_actor_login_lower,
    company_name
), all_all_sub as (
  select
    'commits' as metric,
    actor_login as author,
    company as company,
    count(distinct sha) as value
  from
    hdev_commits_data_{{rnd}}
  group by
    actor_login,
    company
  union all
  select
    metric,
    author,
    company,
    value
  from
    events_type_all
  union all
  select
    'contributions' as metric,
    author,
    coalesce(company_name, '') as company,
    contributions_value as value
  from
    events_overall_all
  union all
  select
    'active_repos' as metric,
    author,
    coalesce(company_name, '') as company,
    active_repos_value as value
  from
    events_overall_all
  union all
  select
    'events' as metric,
    author,
    coalesce(company_name, '') as company,
    events_value as value
  from
    events_overall_all
  union all
  select
    'comments' as metric,
    dup_user_login_lower as author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_comments_{{rnd}}
  where
    (dup_user_login_lower {{exclude_bots}})
  group by
    dup_user_login_lower,
    company_name
  union all
  select
    case is_pull_request when true then 'prs' else 'issues' end as metric,
    dup_user_login_lower as author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_issues_{{rnd}}
  where
    (dup_user_login_lower {{exclude_bots}})
  group by
    is_pull_request,
    dup_user_login_lower,
    company_name
  union all
  select
    'merged_prs' as metric,
    dup_user_login_lower as author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_merged_prs_{{rnd}}
  where
    (dup_user_login_lower {{exclude_bots}})
  group by
    dup_user_login_lower,
    company_name
), all_all as (
  select
    metric,
    author,
    company,
    value
  from
    all_all_sub
  where
    (metric = 'events' and value > 100 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'active_repos' and value > 3 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'contributions' and value > 10 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'commit_comments' and value > 3 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'comments' and value > 20 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'reviews' and value > 15 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'issue_comments' and value > 20 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'review_comments' and value > 20 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric in ('commits','pushes','issues','prs','merged_prs') and value > 0.8 * {{project_scale}} * sqrt({{range}}/1450.0))
), events_type_rg as (
  select
    case type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    repo_group,
    dup_actor_login_lower as author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_events_{{rnd}}
  where
    repo_group is not null
    and type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and (dup_actor_login_lower {{exclude_bots}})
  group by
    type,
    repo_group,
    dup_actor_login_lower,
    coalesce(company_name, '')
), events_overall_rg as (
  select
    repo_group,
    dup_actor_login_lower as author,
    coalesce(company_name, '') as company,
    count(distinct id) as events_value,
    count(distinct repo_id) as active_repos_value,
    count(distinct id) filter (
      where type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
    ) as contributions_value
  from
    hdev_events_{{rnd}}
  where
    repo_group is not null
    and (dup_actor_login_lower {{exclude_bots}})
  group by
    repo_group,
    dup_actor_login_lower,
    coalesce(company_name, '')
), rg_all_sub as (
  select
    'commits' as metric,
    repo_group,
    actor_login as author,
    company as company,
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
    metric,
    repo_group,
    author,
    company,
    value
  from
    events_type_rg
  union all
  select
    'contributions' as metric,
    repo_group,
    author,
    company,
    contributions_value as value
  from
    events_overall_rg
  union all
  select
    'active_repos' as metric,
    repo_group,
    author,
    company,
    active_repos_value as value
  from
    events_overall_rg
  union all
  select
    'events' as metric,
    repo_group,
    author,
    company,
    events_value as value
  from
    events_overall_rg
  union all
  select
    'comments' as metric,
    repo_group,
    dup_user_login_lower as author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_comments_{{rnd}}
  where
    repo_group is not null
    and (dup_user_login_lower {{exclude_bots}})
  group by
    repo_group,
    dup_user_login_lower,
    coalesce(company_name, '')
  union all
  select
    case is_pull_request when true then 'prs' else 'issues' end as metric,
    repo_group,
    dup_user_login_lower as author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_issues_{{rnd}}
  where
    repo_group is not null
    and (dup_user_login_lower {{exclude_bots}})
  group by
    repo_group,
    is_pull_request,
    dup_user_login_lower,
    coalesce(company_name, '')
  union all
  select
    'merged_prs' as metric,
    repo_group,
    dup_user_login_lower as author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_merged_prs_{{rnd}}
  where
    repo_group is not null
    and (dup_user_login_lower {{exclude_bots}})
  group by
    repo_group,
    dup_user_login_lower,
    coalesce(company_name, '')
), rg_all as (
  select
    metric,
    repo_group,
    author,
    company,
    value
  from
    rg_all_sub
  where
    (metric = 'events' and value > 80 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'active_repos' and value > 3 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'contributions' and value > 5 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'commit_comments' and value > 2 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'comments' and value > 10 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'reviews' and value > 5 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'issue_comments' and value > 10 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'review_comments' and value > 10 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric in ('commits','pushes','issues','prs','merged_prs') and value > 0.5 * {{project_scale}} * sqrt({{range}}/1450.0))
), events_type_country_all as (
  select
    case type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_events_country_{{rnd}}
  where
    type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and (author {{exclude_bots}})
  group by
    type,
    country,
    author,
    company_name
), events_overall_country_all as (
  select
    country,
    author,
    company_name,
    count(distinct id) as events_value,
    count(distinct repo_id) as active_repos_value,
    count(distinct id) filter (
      where type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
    ) as contributions_value
  from
    hdev_events_country_{{rnd}}
  where
    (author {{exclude_bots}})
  group by
    country,
    author,
    company_name
), country_all_sub as (
  select
    'commits' as metric,
    a.country_name as country,
    a.login as author,
    c.company as company,
    count(distinct c.sha) as value
  from
    hdev_commits_data_{{rnd}} c
  join
    hdev_actors_country_{{rnd}} a
  on
    a.id = c.actor_id
  group by
    a.country_name,
    a.login,
    c.company
  union all
  select
    metric,
    country,
    author,
    company,
    value
  from
    events_type_country_all
  union all
  select
    'contributions' as metric,
    country,
    author,
    coalesce(company_name, '') as company,
    contributions_value as value
  from
    events_overall_country_all
  union all
  select
    'active_repos' as metric,
    country,
    author,
    coalesce(company_name, '') as company,
    active_repos_value as value
  from
    events_overall_country_all
  union all
  select
    'events' as metric,
    country,
    author,
    coalesce(company_name, '') as company,
    events_value as value
  from
    events_overall_country_all
  union all
  select
    'comments' as metric,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_comments_country_{{rnd}}
  where
    (author {{exclude_bots}})
  group by
    country,
    author,
    company_name
  union all
  select
    case is_pull_request when true then 'prs' else 'issues' end as metric,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_issues_country_{{rnd}}
  where
    (author {{exclude_bots}})
  group by
    is_pull_request,
    country,
    author,
    company_name
  union all
  select
    'merged_prs' as metric,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_merged_prs_country_{{rnd}}
  where
    (author {{exclude_bots}})
  group by
    country,
    author,
    company_name
), country_all as (
  select
    metric,
    country,
    author,
    company,
    value
  from
    country_all_sub
  where
    (metric = 'events' and value > 100 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'active_repos' and value > 3 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'contributions' and value > 5 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'commit_comments' and value > 2 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'comments' and value > 10 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'reviews' and value > 5 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'issue_comments' and value > 10 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'review_comments' and value > 10 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric in ('commits','pushes','issues','prs','merged_prs') and value > 0.5 * {{project_scale}} * sqrt({{range}}/1450.0))
), events_type_rg_country as (
  select
    case type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    repo_group,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_events_country_{{rnd}}
  where
    repo_group is not null
    and country is not null
    and type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
    and (author {{exclude_bots}})
  group by
    type,
    repo_group,
    country,
    author,
    coalesce(company_name, '')
), events_overall_rg_country as (
  select
    repo_group,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct repo_id) as active_repos_value,
    count(distinct id) filter (
      where type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
    ) as contributions_value
  from
    hdev_events_country_{{rnd}}
  where
    repo_group is not null
    and country is not null
    and (author {{exclude_bots}})
  group by
    repo_group,
    country,
    author,
    coalesce(company_name, '')
), events_rg_country_events_metric as (
  select
    repo_group,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_events_country_{{rnd}}
  where
    repo_group is not null
    and country is not null
    and (src_login_lower {{exclude_bots}})
  group by
    repo_group,
    country,
    author,
    coalesce(company_name, '')
), rg_country_sub as (
  select
    'commits' as metric,
    c.repo_group,
    a.country_name as country,
    a.login as author,
    c.company as company,
    count(distinct c.sha) as value
  from
    hdev_commits_data_{{rnd}} c
  join
    hdev_actors_country_{{rnd}} a
  on
    a.id = c.actor_id
  where
    c.repo_group is not null
  group by
    c.repo_group,
    a.country_name,
    a.login,
    c.company
  union all
  select
    metric,
    repo_group,
    country,
    author,
    company,
    value
  from
    events_type_rg_country
  union all
  select
    'contributions' as metric,
    repo_group,
    country,
    author,
    company,
    contributions_value as value
  from
    events_overall_rg_country
  union all
  select
    'active_repos' as metric,
    repo_group,
    country,
    author,
    company,
    active_repos_value as value
  from
    events_overall_rg_country
  union all
  select
    'events' as metric,
    repo_group,
    country,
    author,
    company,
    value
  from
    events_rg_country_events_metric
  union all
  select
    'comments' as metric,
    repo_group,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_comments_country_{{rnd}}
  where
    repo_group is not null
    and country is not null
    and (author {{exclude_bots}})
  group by
    repo_group,
    country,
    author,
    coalesce(company_name, '')
  union all
  select
    case is_pull_request when true then 'prs' else 'issues' end as metric,
    repo_group,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_issues_country_{{rnd}}
  where
    repo_group is not null
    and country is not null
    and (author {{exclude_bots}})
  group by
    repo_group,
    is_pull_request,
    country,
    author,
    coalesce(company_name, '')
  union all
  select
    'merged_prs' as metric,
    repo_group,
    country,
    author,
    coalesce(company_name, '') as company,
    count(distinct id) as value
  from
    hdev_merged_prs_country_{{rnd}}
  where
    repo_group is not null
    and country is not null
    and (author {{exclude_bots}})
  group by
    repo_group,
    country,
    author,
    coalesce(company_name, '')
), rg_country as (
  select
    metric,
    repo_group,
    country,
    author,
    company,
    value
  from
    rg_country_sub
  where
    (metric = 'events' and value > 20 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'active_repos' and value > 0.5 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'commit_comments' and value > 0.5 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'comments' and value > 2 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'issue_comments' and value > 2 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'review_comments' and value > 2 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric = 'reviews' and value > 2 * {{project_scale}} * sqrt({{range}}/1450.0))
    or (metric in ('contributions','commits','pushes','issues','prs','merged_prs') and value > 0.2 * {{project_scale}} * sqrt({{range}}/1450.0))
)
select
  'hdev_' || metric || ',All_All' as metric,
  author || '$$$' || company as name,
  value as value
from
  all_all
union
select
  'hdev_' || metric || ',' || repo_group || '_All' as metric,
  author || '$$$' || company as name,
  value as value
from
  rg_all
union
select
  'hdev_' || metric || ',All_' || country as metric,
  author || '$$$' || company as name,
  value as value
from
  country_all
union
select
  'hdev_' || metric || ',' || repo_group || '_' || country as metric,
  author || '$$$' || company as name,
  value as value
from
  rg_country
order by
  metric asc,
  value desc,
  name asc
;

