create temp table repo_groups_{{rnd}} as
select
  rg.id,
  rg.name,
  rg.repo_group
from
  gha_repo_groups rg
join
  trepo_groups trg
on
  trg.repo_group_name = rg.repo_group
where
  rg.repo_group is not null
;
create index on repo_groups_{{rnd}} (id, name);
analyze repo_groups_{{rnd}};

create temp table actors_country_{{rnd}} as
select
  id,
  login,
  country_name
from
  gha_actors
where
  country_name is not null
  and country_name <> ''
;
create index on actors_country_{{rnd}} (id, login);
analyze actors_country_{{rnd}};

create temp table actors_affiliations_{{rnd}} as
select
  aa.actor_id,
  aa.company_name,
  aa.dt_from,
  aa.dt_to
from
  gha_actors_affiliations aa
join
  tcompanies tc
on
  tc.companies_name = aa.company_name
where
  aa.dt_from <= '{{to}}'
  and aa.dt_to >= '{{from}}'
;
create index on actors_affiliations_{{rnd}} (actor_id, dt_from, dt_to);
create index on actors_affiliations_{{rnd}} (company_name);
analyze actors_affiliations_{{rnd}};

create temp table contributions_{{rnd}} as
select
  v.metric,
  e.repo_id,
  e.repo_name,
  e.created_at,
  e.actor_id,
  e.author,
  e.id
from (
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
  order by
    id
) e
cross join lateral (
  values
    ('contributions'),
    (case e.type
      when 'PushEvent' then 'pushes'
      when 'PullRequestReviewCommentEvent' then 'review_comments'
      when 'PullRequestReviewEvent' then 'reviews'
      when 'IssueCommentEvent' then 'issue_comments'
      when 'CommitCommentEvent' then 'commit_comments'
      else null
    end)
) v(metric)
where
  v.metric is not null
union all
select
  'comments' as metric,
  c.repo_id,
  c.repo_name,
  c.created_at,
  c.actor_id,
  c.author,
  c.id
from (
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
  order by
    id
) c
union all
select
  'issues' as metric,
  i.repo_id,
  i.repo_name,
  i.created_at,
  i.actor_id,
  i.author,
  i.id
from (
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
  order by
    id
) i
union all
select
  'prs' as metric,
  p.repo_id,
  p.repo_name,
  p.created_at,
  p.actor_id,
  p.author,
  p.id
from (
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
  order by
    id
) p
union all
select
  'merged_prs' as metric,
  mp.repo_id,
  mp.repo_name,
  mp.created_at,
  mp.actor_id,
  mp.author,
  mp.id
from (
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
  order by
    id
) mp
;
create index on contributions_{{rnd}} (repo_id, repo_name);
create index on contributions_{{rnd}} (actor_id, created_at);
create index on contributions_{{rnd}} (actor_id, author);
create index on contributions_{{rnd}} (metric);
analyze contributions_{{rnd}};

with agg as (
  select
    'cs;' || m || '_' || coalesce(repo_group, 'All') || '_All_All;evs,acts' as metric,
    round(count(distinct id) / {{n}}, 2) as evs,
    count(distinct author) as acts
  from (
    select
      c.metric as m,
      c.id,
      c.author,
      rg.repo_group
    from
      contributions_{{rnd}} c
    left join
      repo_groups_{{rnd}} rg
    on
      rg.id = c.repo_id
      and rg.name = c.repo_name
  ) sub
  group by
    grouping sets ((m), (m, repo_group))
  having
    grouping(repo_group) = 1
    or repo_group is not null

  union all

  select
    'cs;' || m || '_' || coalesce(repo_group, 'All') || '_' || country || '_All;evs,acts' as metric,
    round(count(distinct id) / {{n}}, 2) as evs,
    count(distinct author) as acts
  from (
    select
      c.metric as m,
      c.id,
      c.author,
      rg.repo_group,
      a.country_name as country
    from
      contributions_{{rnd}} c
    join
      actors_country_{{rnd}} a
    on
      a.id = c.actor_id
      and a.login = c.author
    left join
      repo_groups_{{rnd}} rg
    on
      rg.id = c.repo_id
      and rg.name = c.repo_name
  ) sub
  group by
    grouping sets ((m, country), (m, repo_group, country))
  having
    grouping(repo_group) = 1
    or repo_group is not null

  union all

  select
    'cs;' || m || '_' || coalesce(repo_group, 'All') || '_All_' || company || ';evs,acts' as metric,
    round(count(distinct id) / {{n}}, 2) as evs,
    count(distinct author) as acts
  from (
    select
      c.metric as m,
      c.id,
      c.author,
      rg.repo_group,
      aa.company_name as company
    from
      contributions_{{rnd}} c
    join
      actors_affiliations_{{rnd}} aa
    on
      aa.actor_id = c.actor_id
      and aa.dt_from <= c.created_at
      and aa.dt_to > c.created_at
    left join
      repo_groups_{{rnd}} rg
    on
      rg.id = c.repo_id
      and rg.name = c.repo_name
  ) sub
  group by
    grouping sets ((m, company), (m, repo_group, company))
  having
    grouping(repo_group) = 1
    or repo_group is not null

  union all

  select
    'cs;' || m || '_' || coalesce(repo_group, 'All') || '_' || country || '_' || company || ';evs,acts' as metric,
    round(count(distinct id) / {{n}}, 2) as evs,
    count(distinct author) as acts
  from (
    select
      c.metric as m,
      c.id,
      c.author,
      rg.repo_group,
      a.country_name as country,
      aa.company_name as company
    from
      contributions_{{rnd}} c
    join
      actors_country_{{rnd}} a
    on
      a.id = c.actor_id
      and a.login = c.author
    join
      actors_affiliations_{{rnd}} aa
    on
      aa.actor_id = c.actor_id
      and aa.dt_from <= c.created_at
      and aa.dt_to > c.created_at
    left join
      repo_groups_{{rnd}} rg
    on
      rg.id = c.repo_id
      and rg.name = c.repo_name
  ) sub
  group by
    grouping sets ((m, country, company), (m, repo_group, country, company))
  having
    grouping(repo_group) = 1
    or repo_group is not null
)
select
  metric,
  evs,
  acts
from
  agg
union all
select
  replace(metric, 'cs;contributions_', 'cs;events_') as metric,
  evs,
  acts
from
  agg
where
  metric like 'cs;contributions\_%' escape '\'
;

