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
    order by
      e.id
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
    order by
      c.id
  ), issues_prs as (
    select distinct on (i.id)
      r.repo_name,
      i.created_at,
      i.user_id as actor_id,
      i.dup_user_login as author,
      i.id,
      i.is_pull_request
    from
      gha_issues i
    join
      repos_{{rnd}} r
    on
      i.dup_repo_name = r.repo_name
    where
      i.created_at >= '{{from}}'
      and i.created_at < '{{to}}'
      and (lower(i.dup_user_login) {{exclude_bots}})
    order by
      i.id
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
    order by
      p.id
  )
  select
    v.metric,
    e.repo_name,
    e.created_at,
    e.actor_id,
    e.author,
    e.id
  from
    events e
  cross join lateral (
    values
      ('contributions'),
      ('events'),
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
    c.repo_name,
    c.created_at,
    c.actor_id,
    c.author,
    c.id
  from
    comments c
  union all
  select
    case when ip.is_pull_request then 'prs' else 'issues' end as metric,
    ip.repo_name,
    ip.created_at,
    ip.actor_id,
    ip.author,
    ip.id
  from
    issues_prs ip
  union all
  select
    'merged_prs' as metric,
    mp.repo_name,
    mp.created_at,
    mp.actor_id,
    mp.author,
    mp.id
  from
    merged_prs mp
);
create index on contributions_{{rnd}}(actor_id, created_at);
create index on contributions_{{rnd}}(actor_id, author);
create index on contributions_{{rnd}}(metric, repo_name);
analyze contributions_{{rnd}};

create temp table contrib_actor_logins_{{rnd}} as (
  select distinct
    actor_id,
    author
  from
    contributions_{{rnd}}
);
create index on contrib_actor_logins_{{rnd}}(actor_id, author);
analyze contrib_actor_logins_{{rnd}};

create temp table actors_country_{{rnd}} as (
  select
    a.id as actor_id,
    a.login as author,
    a.country_name as country
  from
    gha_actors a
  join
    contrib_actor_logins_{{rnd}} cal
  on
    cal.actor_id = a.id
    and cal.author = a.login
  where
    a.country_name is not null
);
create index on actors_country_{{rnd}}(actor_id, author);
create index on actors_country_{{rnd}}(country);
analyze actors_country_{{rnd}};

create temp table actors_affiliations_{{rnd}} as (
  select
    aa.actor_id,
    aa.company_name,
    aa.dt_from,
    aa.dt_to
  from
    gha_actors_affiliations aa
  join
    tcompanies c
  on
    c.companies_name = aa.company_name
  join (
    select distinct
      actor_id
    from
      contrib_actor_logins_{{rnd}}
  ) a
  on
    a.actor_id = aa.actor_id
  where
    aa.dt_from <= '{{to}}'
    and aa.dt_to >= '{{from}}'
);
create index on actors_affiliations_{{rnd}}(actor_id, dt_from, dt_to);
create index on actors_affiliations_{{rnd}}(company_name);
analyze actors_affiliations_{{rnd}};

create temp table contributions_country_{{rnd}} as (
  select
    c.metric,
    c.created_at,
    c.repo_name,
    ac.country,
    c.author,
    c.actor_id,
    c.id
  from
    contributions_{{rnd}} c
  join
    actors_country_{{rnd}} ac
  on
    ac.actor_id = c.actor_id
    and ac.author = c.author
);
create index on contributions_country_{{rnd}}(actor_id, created_at);
create index on contributions_country_{{rnd}}(metric, repo_name, country);
analyze contributions_country_{{rnd}};

create temp table contributions_company_{{rnd}} as (
  select
    c.metric,
    c.repo_name,
    aa.company_name as company,
    c.author,
    c.id
  from
    contributions_{{rnd}} c
  join
    actors_affiliations_{{rnd}} aa
  on
    aa.actor_id = c.actor_id
    and aa.dt_from <= c.created_at
    and aa.dt_to > c.created_at
);
create index on contributions_company_{{rnd}}(metric, repo_name, company);
analyze contributions_company_{{rnd}};

with contributions_country_company as (
  select
    c.metric,
    c.repo_name,
    c.country,
    aa.company_name as company,
    c.author,
    c.id
  from
    contributions_country_{{rnd}} c
  join
    actors_affiliations_{{rnd}} aa
  on
    aa.actor_id = c.actor_id
    and aa.dt_from <= c.created_at
    and aa.dt_to > c.created_at
)
select
  metric,
  evs,
  acts
from (
  select
    case
      when grouping(repo_name) = 1 then 'cs;' || metric || '_All_All_All;evs,acts'
      else 'cs;' || metric || '_' || repo_name || '_All_All;evs,acts'
    end as metric,
    round(count(distinct id) / {{n}}, 2) as evs,
    count(distinct author) as acts
  from
    contributions_{{rnd}}
  group by
    grouping sets ((metric), (metric, repo_name))

  union
  select
    case
      when grouping(repo_name) = 1 then 'cs;' || metric || '_All_' || country || '_All;evs,acts'
      else 'cs;' || metric || '_' || repo_name || '_' || country || '_All;evs,acts'
    end as metric,
    round(count(distinct id) / {{n}}, 2) as evs,
    count(distinct author) as acts
  from
    contributions_country_{{rnd}}
  group by
    grouping sets ((metric, country), (metric, repo_name, country))

  union
  select
    case
      when grouping(repo_name) = 1 then 'cs;' || metric || '_All_All_' || company || ';evs,acts'
      else 'cs;' || metric || '_' || repo_name || '_All_' || company || ';evs,acts'
    end as metric,
    round(count(distinct id) / {{n}}, 2) as evs,
    count(distinct author) as acts
  from
    contributions_company_{{rnd}}
  group by
    grouping sets ((metric, company), (metric, repo_name, company))

  union
  select
    case
      when grouping(repo_name) = 1 then 'cs;' || metric || '_All_' || country || '_' || company || ';evs,acts'
      else 'cs;' || metric || '_' || repo_name || '_' || country || '_' || company || ';evs,acts'
    end as metric,
    round(count(distinct id) / {{n}}, 2) as evs,
    count(distinct author) as acts
  from
    contributions_country_company
  group by
    grouping sets (
      (metric, country, company),
      (metric, repo_name, country, company)
    )
) s
;

