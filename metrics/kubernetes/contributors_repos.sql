-- explain (analyze true)
-- explain (analyze, costs, verbose, buffers)
create temp table repos_{{rnd}} as (
  select
    repo_name
  from
    trepos
);
create index on repos_{{rnd}}(repo_name);
analyze repos_{{rnd}};

create temp table contributions_{{rnd}} as (
  with events as (
    select distinct on (e.id)
      e.id,
      r.repo_name,
      e.created_at,
      e.type,
      e.actor_id,
      e.dup_actor_login as author
    from
      gha_events e
    join
      repos_{{rnd}} r
    on
      e.dup_repo_name = r.repo_name
    where
      e.type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
      and e.created_at >= '{{from}}'
      and e.created_at < '{{to}}'
      and (lower(e.dup_actor_login) {{exclude_bots}})
  ), comments as (
    select distinct on (c.id)
      r.repo_name,
      c.created_at,
      c.user_id as actor_id,
      c.dup_user_login as author,
      c.id
    from
      gha_comments c
    join
      repos_{{rnd}} r
    on
      c.dup_repo_name = r.repo_name
    where
      c.created_at >= '{{from}}'
      and c.created_at < '{{to}}'
      and (lower(c.dup_user_login) {{exclude_bots}})
  ), issues as (
    select distinct on (i.id)
      r.repo_name,
      i.created_at,
      i.user_id as actor_id,
      i.dup_user_login as author,
      i.id
    from
      gha_issues i
    join
      repos_{{rnd}} r
    on
      i.dup_repo_name = r.repo_name
    where
      i.created_at >= '{{from}}'
      and i.created_at < '{{to}}'
      and i.is_pull_request = false
      and (lower(i.dup_user_login) {{exclude_bots}})
  ), prs as (
    select distinct on (i.id)
      r.repo_name,
      i.created_at,
      i.user_id as actor_id,
      i.dup_user_login as author,
      id
    from
      gha_issues i
    join
      repos_{{rnd}} r
    on
      i.dup_repo_name = r.repo_name
    where
      i.created_at >= '{{from}}'
      and i.created_at < '{{to}}'
      and i.is_pull_request = true
      and (lower(i.dup_user_login) {{exclude_bots}})
  ), merged_prs as (
    select distinct on (p.id)
      r.repo_name,
      p.created_at,
      p.user_id as actor_id,
      p.dup_user_login as author,
      p.id
    from
      gha_pull_requests p
    join
      repos_{{rnd}} r
    on
      p.dup_repo_name = r.repo_name
    where
      p.merged_at >= '{{from}}'
      and p.merged_at < '{{to}}'
      and (lower(p.dup_user_login) {{exclude_bots}})
  )
  select
    case type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
    end as metric,
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
    repo_name,
    created_at,
    actor_id,
    author,
    id
  from
    events
  union select
    'comments' as metric,
    repo_name,
    created_at,
    actor_id,
    author,
    id
  from
    comments
  union select
    'issues' as metric,
    repo_name,
    created_at,
    actor_id,
    author,
    id
  from
    issues
  union select
    'prs' as metric,
    repo_name,
    created_at,
    actor_id,
    author,
    id
  from
    prs
  union select
    'merged_prs' as metric,
    repo_name,
    created_at,
    actor_id,
    author,
    id
  from
    merged_prs
  union select
    'events' as metric,
    repo_name,
    created_at,
    actor_id,
    author,
    id
  from
    events
);
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
create index on contributions_country_{{rnd}}(actor_id);
create index on contributions_country_{{rnd}}(created_at);
analyze contributions_country_{{rnd}};

with contributions_company as (
  select
    c.metric,
    c.created_at,
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
), contributions_country_company as (
  select
    c.metric,
    c.created_at,
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
  select 'cs;' || metric || '_' || repo_name || '_All_All;evs,acts' as metric,
  round(count(distinct id) / {{n}}, 2) as evs,
  count(distinct author) as acts
from
  contributions_{{rnd}}
group by
  metric,
  repo_name
union select 'cs;' || metric || '_All_' || country || '_All;evs,acts' as metric,
  round(count(distinct id) / {{n}}, 2) as evs,
  count(distinct author) as acts
from
  contributions_country_{{rnd}}
group by
  metric,
  country
union select 'cs;' || metric || '_'|| repo_name || '_' || country || '_All;evs,acts' as metric,
  round(count(distinct id) / {{n}}, 2) as evs,
  count(distinct author) as acts
from
  contributions_country_{{rnd}}
group by
  metric,
  repo_name,
  country
union select 'cs;' || metric || '_All_All_' || company || ';evs,acts' as metric,
  round(count(distinct id) / {{n}}, 2) as evs,
  count(distinct author) as acts
from
  contributions_company
group by
  metric,
  company
union select 'cs;' || metric || '_' || repo_name || '_All_' || company || ';evs,acts' as metric,
  round(count(distinct id) / {{n}}, 2) as evs,
  count(distinct author) as acts
from
  contributions_company
group by
  metric,
  repo_name,
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
union select 'cs;' || metric || '_' || repo_name || '_' || country || '_' || company || ';evs,acts' as metric,
  round(count(distinct id) / {{n}}, 2) as evs,
  count(distinct author) as acts
from
  contributions_country_company
group by
  metric,
  repo_name,
  country,
  company
/*
order by
  acts desc,
  evs desc
*/
;
