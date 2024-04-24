-- explain (analyze, costs, verbose, buffers)
create temp table contributions_{{rnd}} as (
  with events as (
    select distinct on (id)
      id,
      repo_id,
      dup_repo_name as repo_name,
      created_at,
      type,
      actor_id,
      dup_actor_login as author
    from
      gha_events
    where
      type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
      and created_at >= '{{from}}'
      and created_at < '{{to}}'
      and (lower(dup_actor_login) {{exclude_bots}})
  ), comments as (
    select distinct on (id)
      dup_repo_id as repo_id,
      dup_repo_name as repo_name,
      created_at,
      user_id as actor_id,
      dup_user_login as author,
      id
    from
      gha_comments
    where
      created_at >= '{{from}}'
      and created_at < '{{to}}'
      and (lower(dup_user_login) {{exclude_bots}})
  ), issues as (
    select distinct on (id)
      dup_repo_id as repo_id,
      dup_repo_name as repo_name,
      created_at,
      user_id as actor_id,
      dup_user_login as author,
      id
    from
      gha_issues
    where
      created_at >= '{{from}}'
      and created_at < '{{to}}'
      and is_pull_request = false
      and (lower(dup_user_login) {{exclude_bots}})
  ), prs as (
    select distinct on (id)
      dup_repo_id as repo_id,
      dup_repo_name as repo_name,
      created_at,
      user_id as actor_id,
      dup_user_login as author,
      id
    from
      gha_issues
    where
      created_at >= '{{from}}'
      and created_at < '{{to}}'
      and is_pull_request = true
      and (lower(dup_user_login) {{exclude_bots}})
  ), merged_prs as (
    select distinct on (id)
      dup_repo_id as repo_id,
      dup_repo_name as repo_name,
      created_at,
      user_id as actor_id,
      dup_user_login as author,
      id
    from
      gha_pull_requests
    where
      merged_at >= '{{from}}'
      and merged_at < '{{to}}'
      and (lower(dup_user_login) {{exclude_bots}})
  )
  select
    case type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
    repo_id,
    repo_name,
    created_at,
    actor_id,
    author,
    id
  from
    events
  where
    type in (
      'PushEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent',
      'IssueCommentEvent', 'CommitCommentEvent'
    )
  union select
    'contributions' as metric,
    repo_id,
    repo_name,
    created_at,
    actor_id,
    author,
    id
  from
    events
  union select
    'comments' as metric,
    repo_id,
    repo_name,
    created_at,
    actor_id,
    author,
    id
  from
    comments
  union select
    'issues' as metric,
    repo_id,
    repo_name,
    created_at,
    actor_id,
    author,
    id
  from
    issues
  union select
    'prs' as metric,
    repo_id,
    repo_name,
    created_at,
    actor_id,
    author,
    id
  from
    prs
  union select
    'merged_prs' as metric,
    repo_id,
    repo_name,
    created_at,
    actor_id,
    author,
    id
  from
    merged_prs
  union select
    'events' as metric,
    repo_id,
    repo_name,
    created_at,
    actor_id,
    author,
    id
  from
    events
);
create index on contributions_{{rnd}}(id);
create index on contributions_{{rnd}}(repo_id);
create index on contributions_{{rnd}}(repo_name);
create index on contributions_{{rnd}}(created_at);
create index on contributions_{{rnd}}(actor_id);
create index on contributions_{{rnd}}(author);
analyze contributions_{{rnd}};

create temp table actors_affiliations_{{rnd}} as (
  select
    actor_id,
    company_name,
    dt_from,
    dt_to
  from
    gha_actors_affiliations aa
  inner join
    tcompanies c
  on
    c.companies_name = aa.company_name
  where
    aa.dt_from <= '{{to}}'
    and aa.dt_to >= '{{from}}'
);
create index on actors_affiliations_{{rnd}}(actor_id);
create index on actors_affiliations_{{rnd}}(dt_from);
create index on actors_affiliations_{{rnd}}(dt_to);
analyze actors_affiliations_{{rnd}};

create temp table contributions_country_{{rnd}} as (
  select
    c.metric,
    c.created_at,
    c.repo_id,
    c.repo_name,
    a.country_name as country,
    c.author,
    c.actor_id,
    c.id
  from
    contributions_{{rnd}} c
  inner join
    gha_actors a
  on
    c.actor_id = a.id
    and c.author = a.login
    -- previous was using the line below with 'OR'
    -- c.actor_id = a.id or c.author = a.login
    -- Can also be one of those:
    -- c.author = a.login
    -- c.actor_id = a.id
  where
    a.country_name is not null
);
create index on contributions_country_{{rnd}}(id);
create index on contributions_country_{{rnd}}(actor_id);
create index on contributions_country_{{rnd}}(created_at);
create index on contributions_country_{{rnd}}(repo_id);
create index on contributions_country_{{rnd}}(repo_name);
analyze contributions_country_{{rnd}};


create temp table contributions_company_{{rnd}} as (
  select
    c.metric,
    c.created_at,
    c.repo_id,
    c.repo_name,
    aa.company_name as company,
    c.author,
    c.actor_id,
    c.id
  from
    contributions_{{rnd}} c
  inner join
    actors_affiliations_{{rnd}} aa
  on
    aa.actor_id = c.actor_id
    and aa.dt_from <= c.created_at
    and aa.dt_to > c.created_at
);
create index on contributions_company_{{rnd}}(id);
create index on contributions_company_{{rnd}}(repo_id);
create index on contributions_company_{{rnd}}(repo_name);
analyze contributions_company_{{rnd}};


create temp table contributions_repo_group_country_{{rnd}} as (
  select
    c.metric,
    c.created_at,
    c.repo_id,
    c.repo_name,
    coalesce(ecf.repo_group, r.repo_group) as repo_group,
    c.country,
    c.author,
    c.actor_id,
    c.id
  from
    contributions_country_{{rnd}} c
  inner join
    gha_repos r
  on
    c.repo_id = r.id
    and c.repo_name = r.name
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = c.id
  where
    coalesce(ecf.repo_group, r.repo_group) is not null
);
create index on contributions_repo_group_country_{{rnd}}(actor_id);
create index on contributions_repo_group_country_{{rnd}}(created_at);
analyze contributions_repo_group_country_{{rnd}};

with contributions_repo_group as (
  select
    c.metric,
    c.created_at,
    c.repo_id,
    c.repo_name,
    coalesce(ecf.repo_group, r.repo_group) as repo_group,
    c.author,
    c.actor_id,
    c.id
  from
    contributions_{{rnd}} c
  inner join
    gha_repos r
  on
    c.repo_id = r.id
    and c.repo_name = r.name
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = c.id
  where
    coalesce(ecf.repo_group, r.repo_group) is not null
), contributions_country_company as (
  select
    c.metric,
    c.created_at,
    c.repo_id,
    c.repo_name,
    c.country,
    aa.company_name as company,
    c.author,
    c.actor_id,
    c.id
  from
    contributions_country_{{rnd}} c
  inner join
    actors_affiliations_{{rnd}} aa
  on
    aa.actor_id = c.actor_id
    and aa.dt_from <= c.created_at
    and aa.dt_to > c.created_at
), contributions_repo_group_company as (
  select
    c.metric,
    c.created_at,
    c.repo_id,
    c.repo_name,
    coalesce(ecf.repo_group, r.repo_group) as repo_group,
    c.company,
    c.author,
    c.actor_id,
    c.id
  from
    contributions_company_{{rnd}} c
  inner join
    gha_repos r
  on
    c.repo_id = r.id
    and c.repo_name = r.name
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = c.id
  where
    coalesce(ecf.repo_group, r.repo_group) is not null
), contributions_repo_group_country_company as (
  select
    c.metric,
    c.created_at,
    c.repo_id,
    c.repo_name,
    c.repo_group,
    c.country,
    aa.company_name as company,
    c.author,
    c.actor_id,
    c.id
  from
    contributions_repo_group_country_{{rnd}} c
  inner join
    actors_affiliations_{{rnd}} aa
  on
    aa.actor_id = c.actor_id
    and aa.dt_from <= c.created_at
    and aa.dt_to > c.created_at
)
select 
  'cs;' || metric || '_All_All_All;evs,acts' as metric,
  round(count(distinct id) / {{n}}, 2) as evs,
  count(distinct author) as acts
from
  contributions_{{rnd}}
group by
  metric
union
  select 'cs;' || metric || '_' || repo_group || '_All_All;evs,acts' as metric,
  round(count(distinct id) / {{n}}, 2) as evs,
  count(distinct author) as acts
from
  contributions_repo_group
group by
  metric,
  repo_group
union select 'cs;' || metric || '_All_' || country || '_All;evs,acts' as metric,
  round(count(distinct id) / {{n}}, 2) as evs,
  count(distinct author) as acts
from
  contributions_country_{{rnd}}
group by
  metric,
  country
union select 'cs;' || metric || '_'|| repo_group || '_' || country || '_All;evs,acts' as metric,
  round(count(distinct id) / {{n}}, 2) as evs,
  count(distinct author) as acts
from
  contributions_repo_group_country_{{rnd}}
group by
  metric,
  repo_group,
  country
union select 'cs;' || metric || '_All_All_' || company || ';evs,acts' as metric,
  round(count(distinct id) / {{n}}, 2) as evs,
  count(distinct author) as acts
from
  contributions_company_{{rnd}}
group by
  metric,
  company
union select 'cs;' || metric || '_' || repo_group || '_All_' || company || ';evs,acts' as metric,
  round(count(distinct id) / {{n}}, 2) as evs,
  count(distinct author) as acts
from
  contributions_repo_group_company
group by
  metric,
  repo_group,
  company
union select 'cs;' || metric || '_All_' || country || '_' || company || ';evs,acts' as metric,
  round(count(distinct id) / {{n}}, 2) as evs,
  count(distinct author) as acts
from
  contributions_country_company
group by
  metric,
  country,
  company
union select 'cs;' || metric || '_' || repo_group || '_' || country || '_' || company || ';evs,acts' as metric,
  round(count(distinct id) / {{n}}, 2) as evs,
  count(distinct author) as acts
from
  contributions_repo_group_country_company
group by
  metric,
  repo_group,
  country,
  company
;
/*
order by
  acts desc,
  evs desc
*/
