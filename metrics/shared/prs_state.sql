create temp table all_prs_i as (
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
    and updated_at >= '2024-04-01'
    and updated_at < '2024-04-08'
);
create index on all_prs_i(number);
create index on all_prs_i(dup_repo_id);
create index on all_prs_i(dup_repo_name);
analyze all_prs_i;

create temp table all_prs_p as (
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
    all_prs_i i
  inner join
    gha_pull_requests pr
  on
    i.number = pr.number
    and i.dup_repo_id = pr.dup_repo_id
    and i.dup_repo_name = pr.dup_repo_name
  where
    -- this was not in the original query: but this was a bug IMHO
    pr.updated_at >= '2024-04-01'
    and pr.updated_at < '2024-04-08'
);
create index on all_prs_p(id);
create index on all_prs_p(number);
create index on all_prs_p(pr_id);
create index on all_prs_p(dup_repo_id);
create index on all_prs_p(dup_repo_name);
analyze all_prs_p;

create temp table all_prs_ip as (
  select distinct
    i.id,
    i.event_id,
    i.merged_at,
    i.closed_at,
    i.dup_repo_id,
    i.dup_repo_name
  from
    all_prs_p i
  inner join
    gha_issues_pull_requests ipr
  on
    ipr.issue_id = i.id
    and ipr.pull_request_id = i.pr_id
    and i.dup_repo_id = ipr.repo_id
    and i.dup_repo_name = ipr.repo_name
    and ipr.number = i.number
);
create index on all_prs_ip(event_id);
create index on all_prs_ip(merged_at);
create index on all_prs_ip(closed_at);
analyze all_prs_ip;

create temp table all_prs as (
  select distinct
    id,
    dup_repo_id,
    dup_repo_name
  from
    all_prs_ip
  where
    merged_at is not null
    or closed_at is null
);
create index on all_prs(id);
create index on all_prs(dup_repo_id);
create index on all_prs(dup_repo_name);
analyze all_prs;

create temp table approved_prs as (
  select distinct
    i.id
  from
    all_prs_ip i
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
create index on approved_prs(id);
analyze approved_prs;

select
  'pr_appr;All;appr,wait' as name,
  round(count(distinct prs.id) filter (where a.id is not null) / {{n}}, 2) as approved,
  round(count(distinct prs.id) filter (where a.id is null) / {{n}}, 2) as awaiting
from
  all_prs prs
left join 
  approved_prs a
on
  prs.id = a.id
union select 'pr_appr;' || r.repo_group ||';appr,wait' as name,
  round(count(distinct prs.id) filter (where a.id is not null) / {{n}}, 2) as approved,
  round(count(distinct prs.id) filter (where a.id is null) / {{n}}, 2) as awaiting
from
  gha_repo_groups r
join
  all_prs prs
on
  prs.dup_repo_name = r.name
  and prs.dup_repo_id = r.id
  and r.repo_group is not null
  and r.repo_group in (select all_repo_group_name from tall_repo_groups)
left join 
  approved_prs a
on
  prs.id = a.id
group by
  r.repo_group
order by
  approved desc,
  awaiting desc,
  name asc
;
