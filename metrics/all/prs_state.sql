create temp table all_prs_{{rnd}}_i as (
  select distinct
    id,
    event_id,
    number,
    dup_repo_name,
    dup_repo_id
  from
    gha_issues
  where
    is_pull_request = true
    and updated_at >= '{{from}}'
    and updated_at < '{{to}}'
);
create index on all_prs_{{rnd}}_i(number);
create index on all_prs_{{rnd}}_i(dup_repo_id);
create index on all_prs_{{rnd}}_i(dup_repo_name);
analyze all_prs_{{rnd}}_i;

create temp table all_prs_{{rnd}}_p as (
  select distinct
    i.id,
    i.event_id,
    i.number,
    pr.merged_at,
    pr.closed_at,
    pr.id as pr_id,
    i.dup_repo_id,
    i.dup_repo_name
  from
    all_prs_{{rnd}}_i i
  inner join
    gha_pull_requests pr
  on
    i.number = pr.number
    and i.dup_repo_id = pr.dup_repo_id
    and i.dup_repo_name = pr.dup_repo_name
  where
    -- this was not in the original query: but this was a bug IMHO
    pr.updated_at >= '{{from}}'
    and pr.updated_at < '{{to}}'
);
create index on all_prs_{{rnd}}_p(id);
create index on all_prs_{{rnd}}_p(number);
create index on all_prs_{{rnd}}_p(pr_id);
create index on all_prs_{{rnd}}_p(dup_repo_id);
create index on all_prs_{{rnd}}_p(dup_repo_name);
analyze all_prs_{{rnd}}_p;

create temp table all_prs_{{rnd}}_ip as (
  select distinct
    i.id,
    i.event_id,
    i.merged_at,
    i.closed_at,
    i.dup_repo_id,
    i.dup_repo_name
  from
    all_prs_{{rnd}}_p i
  inner join
    gha_issues_pull_requests ipr
  on
    ipr.issue_id = i.id
    and ipr.pull_request_id = i.pr_id
    and i.dup_repo_id = ipr.repo_id
    and i.dup_repo_name = ipr.repo_name
    and ipr.number = i.number
);
create index on all_prs_{{rnd}}_ip(event_id);
create index on all_prs_{{rnd}}_ip(merged_at);
create index on all_prs_{{rnd}}_ip(closed_at);
analyze all_prs_{{rnd}}_ip;

create temp table all_prs_{{rnd}} as (
  select distinct
    id,
    dup_repo_id,
    dup_repo_name
  from
    all_prs_{{rnd}}_ip
  where
    merged_at is not null
    or closed_at is null
);
create index on all_prs_{{rnd}}(id);
create index on all_prs_{{rnd}}(dup_repo_id);
create index on all_prs_{{rnd}}(dup_repo_name);
analyze all_prs_{{rnd}};

create temp table approved_prs_{{rnd}} as (
  select distinct
    i.id
  from
    all_prs_{{rnd}}_ip i
  join
    gha_comments c
  on
    i.event_id = c.event_id
  where
    i.merged_at is not null
    or (
      i.closed_at is null
      and substring(c.body from '(?i)(?:^|\n|\r)\s*/(approve|lgtm)\s*(?:\n|\r|$)') is not null
    )
);
create index on approved_prs_{{rnd}}(id);
analyze approved_prs_{{rnd}};

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
union select 'pr_appr;' || r.repo_group ||';appr,wait' as name,
  round(count(distinct prs.id) filter (where a.id is not null) / {{n}}, 2) as approved,
  round(count(distinct prs.id) filter (where a.id is null) / {{n}}, 2) as awaiting
from
  gha_repo_groups r
join
  all_prs_{{rnd}} prs
on
  prs.dup_repo_name = r.name
  and prs.dup_repo_id = r.id
  and r.repo_group is not null
  and r.repo_group in (select all_repo_group_name from tall_repo_groups)
left join 
  approved_prs_{{rnd}} a
on
  prs.id = a.id
group by
  r.repo_group
order by
  approved desc,
  awaiting desc,
  name asc
;
