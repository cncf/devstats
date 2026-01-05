create temp table pr_appr_{{rnd}}_i as (
  select
    i.id,
    i.event_id,
    i.updated_at,
    i.number,
    i.dup_repo_name,
    i.dup_repo_id
  from
    gha_issues i
  where
    i.is_pull_request = true
    and i.updated_at >= '{{from}}'
    and i.updated_at < '{{to}}'
);
create index on pr_appr_{{rnd}}_i(id);
create index on pr_appr_{{rnd}}_i(event_id);
create index on pr_appr_{{rnd}}_i(dup_repo_id, dup_repo_name, number);
create index on pr_appr_{{rnd}}_i(id, updated_at desc, event_id desc);
analyze pr_appr_{{rnd}}_i;

create temp table pr_appr_{{rnd}}_i_ids as (
  select distinct
    id
  from
    pr_appr_{{rnd}}_i
);
create unique index on pr_appr_{{rnd}}_i_ids(id);
analyze pr_appr_{{rnd}}_i_ids;

create temp table pr_appr_{{rnd}}_ipr as (
  select distinct
    ipr.issue_id,
    ipr.pull_request_id,
    ipr.repo_id,
    ipr.repo_name,
    ipr.number
  from
    gha_issues_pull_requests ipr
  join
    pr_appr_{{rnd}}_i_ids ii
  on
    ii.id = ipr.issue_id
);
create index on pr_appr_{{rnd}}_ipr(issue_id);
create index on pr_appr_{{rnd}}_ipr(pull_request_id);
create index on pr_appr_{{rnd}}_ipr(issue_id, pull_request_id);
create index on pr_appr_{{rnd}}_ipr(repo_id, repo_name, number);
analyze pr_appr_{{rnd}}_ipr;

create temp table pr_appr_{{rnd}}_pr as (
  select
    pr.id,
    pr.updated_at,
    pr.number,
    pr.dup_repo_name,
    pr.dup_repo_id,
    pr.merged_at,
    pr.closed_at
  from
    gha_pull_requests pr
  where
    pr.updated_at >= '{{from}}'
    and pr.updated_at < '{{to}}'
    and (
      pr.merged_at is not null
      or pr.closed_at is null
    )
);
create index on pr_appr_{{rnd}}_pr(id);
create index on pr_appr_{{rnd}}_pr(dup_repo_id, dup_repo_name, number);
create index on pr_appr_{{rnd}}_pr(id, dup_repo_id, dup_repo_name, number);
analyze pr_appr_{{rnd}}_pr;

create temp table pr_appr_{{rnd}}_j as (
  select
    i.id,
    i.event_id,
    i.updated_at,
    i.dup_repo_name,
    i.dup_repo_id,
    pr.merged_at,
    pr.closed_at
  from
    pr_appr_{{rnd}}_i i
  join
    pr_appr_{{rnd}}_ipr ipr
  on
    ipr.issue_id = i.id
    and ipr.number = i.number
    and ipr.repo_id = i.dup_repo_id
    and ipr.repo_name = i.dup_repo_name
  join
    pr_appr_{{rnd}}_pr pr
  on
    ipr.pull_request_id = pr.id
    and i.number = pr.number
    and i.dup_repo_id = pr.dup_repo_id
    and i.dup_repo_name = pr.dup_repo_name
    and pr.dup_repo_id = ipr.repo_id
    and pr.dup_repo_name = ipr.repo_name
    and pr.number = ipr.number
);
create index on pr_appr_{{rnd}}_j(id);
create index on pr_appr_{{rnd}}_j(event_id);
create index on pr_appr_{{rnd}}_j(dup_repo_id, dup_repo_name);
create index on pr_appr_{{rnd}}_j(id, updated_at desc, event_id desc);
analyze pr_appr_{{rnd}}_j;

create temp table all_prs_{{rnd}} as (
  select distinct on (id)
    id,
    dup_repo_name,
    dup_repo_id
  from
    pr_appr_{{rnd}}_j
  order by
    id,
    updated_at desc,
    event_id desc
);
create unique index on all_prs_{{rnd}}(id);
create index on all_prs_{{rnd}}(dup_repo_id, dup_repo_name);
analyze all_prs_{{rnd}};

create temp table pr_appr_{{rnd}}_issue_events as (
  select distinct
    event_id
  from
    pr_appr_{{rnd}}_j
);
create unique index on pr_appr_{{rnd}}_issue_events(event_id);
analyze pr_appr_{{rnd}}_issue_events;

create temp table pr_appr_{{rnd}}_comment_events as (
  select distinct
    c.event_id
  from
    gha_comments c
  join
    pr_appr_{{rnd}}_issue_events e
  on
    e.event_id = c.event_id
);
create unique index on pr_appr_{{rnd}}_comment_events(event_id);
analyze pr_appr_{{rnd}}_comment_events;

create temp table pr_appr_{{rnd}}_approval_events as (
  select distinct
    c.event_id
  from
    gha_comments c
  join
    pr_appr_{{rnd}}_issue_events e
  on
    e.event_id = c.event_id
  where
    (
      c.body ilike '%/approve%'
      or c.body ilike '%/lgtm%'
    )
    and substring(c.body from '(?i)(?:^|\n|\r)\s*/(approve|lgtm)\s*(?:\n|\r|$)') is not null
);
create unique index on pr_appr_{{rnd}}_approval_events(event_id);
analyze pr_appr_{{rnd}}_approval_events;

create temp table approved_prs_{{rnd}} as (
  select distinct
    j.id
  from
    pr_appr_{{rnd}}_j j
  join
    pr_appr_{{rnd}}_comment_events ce
  on
    ce.event_id = j.event_id
  where
    j.merged_at is not null

  union

  select distinct
    j.id
  from
    pr_appr_{{rnd}}_j j
  join
    pr_appr_{{rnd}}_approval_events ae
  on
    ae.event_id = j.event_id
  where
    j.closed_at is null
);
create unique index on approved_prs_{{rnd}}(id);
analyze approved_prs_{{rnd}};

create temp table pr_appr_{{rnd}}_groups as (
  select
    r.repo_group,
    p.id
  from
    gha_repos r
  join
    all_prs_{{rnd}} p
  on
    p.dup_repo_name = r.name
    and p.dup_repo_id = r.id
  where
    r.repo_group is not null
);
create index on pr_appr_{{rnd}}_groups(repo_group);
create index on pr_appr_{{rnd}}_groups(id);
create index on pr_appr_{{rnd}}_groups(repo_group, id);
analyze pr_appr_{{rnd}}_groups;

select
  'pr_appr;All;appr,wait' as name,
  round(count(distinct prs.id) filter (where a.id is not null) / {{n}}, 2) as approved,
  round(count(distinct prs.id) filter (where a.id is null) / {{n}}, 2) as awaiting
from
  all_prs_{{rnd}} prs
left join
  approved_prs_{{rnd}} a
on
  prs.id = a.id

union

select
  'pr_appr;' || g.repo_group || ';appr,wait' as name,
  round(count(distinct g.id) filter (where a.id is not null) / {{n}}, 2) as approved,
  round(count(distinct g.id) filter (where a.id is null) / {{n}}, 2) as awaiting
from
  pr_appr_{{rnd}}_groups g
left join
  approved_prs_{{rnd}} a
on
  g.id = a.id
where
  g.repo_group is not null
group by
  g.repo_group

order by
  approved desc,
  awaiting desc,
  name asc
;

