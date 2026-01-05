create temp table pr_appr_{{rnd}}_i as
select distinct
  i.id,
  i.event_id,
  i.number,
  i.dup_repo_name,
  i.dup_repo_id
from
  gha_issues i
where
  i.is_pull_request = true
  and i.updated_at >= '{{from}}'
  and i.updated_at < '{{to}}'
;
create index on pr_appr_{{rnd}}_i(id);
create index on pr_appr_{{rnd}}_i(dup_repo_id, dup_repo_name, number);
analyze pr_appr_{{rnd}}_i;

create temp table pr_appr_{{rnd}}_ipr as
select distinct
  i.id,
  i.event_id,
  i.number,
  i.dup_repo_id,
  i.dup_repo_name,
  ipr.pull_request_id as pr_id
from
  pr_appr_{{rnd}}_i i
join
  gha_issues_pull_requests ipr
on
  ipr.issue_id = i.id
  and ipr.repo_id = i.dup_repo_id
  and ipr.repo_name = i.dup_repo_name
  and ipr.number = i.number
;
create index on pr_appr_{{rnd}}_ipr(id);
create index on pr_appr_{{rnd}}_ipr(event_id);
create index on pr_appr_{{rnd}}_ipr(pr_id);
create index on pr_appr_{{rnd}}_ipr(dup_repo_id, dup_repo_name, number);
analyze pr_appr_{{rnd}}_ipr;

create temp table pr_appr_{{rnd}}_ip as
select distinct
  x.id,
  x.event_id,
  pr.merged_at,
  pr.closed_at,
  x.dup_repo_id,
  x.dup_repo_name
from
  pr_appr_{{rnd}}_ipr x
join
  gha_pull_requests pr
on
  pr.id = x.pr_id
  and pr.number = x.number
  and pr.dup_repo_id = x.dup_repo_id
  and pr.dup_repo_name = x.dup_repo_name
where
  pr.updated_at >= '{{from}}'
  and pr.updated_at < '{{to}}'
;
create index on pr_appr_{{rnd}}_ip(id);
create index on pr_appr_{{rnd}}_ip(event_id);
create index on pr_appr_{{rnd}}_ip(merged_at);
create index on pr_appr_{{rnd}}_ip(closed_at);
create index on pr_appr_{{rnd}}_ip(dup_repo_id, dup_repo_name);
analyze pr_appr_{{rnd}}_ip;

create temp table all_prs_{{rnd}} as
select distinct
  id,
  dup_repo_id,
  dup_repo_name
from
  pr_appr_{{rnd}}_ip
where
  merged_at is not null
  or closed_at is null
;
create index on all_prs_{{rnd}}(id);
create index on all_prs_{{rnd}}(dup_repo_id, dup_repo_name);
analyze all_prs_{{rnd}};

create temp table pr_appr_{{rnd}}_merged_rows as
select distinct
  id,
  event_id
from
  pr_appr_{{rnd}}_ip
where
  merged_at is not null
;
create index on pr_appr_{{rnd}}_merged_rows(event_id);
create index on pr_appr_{{rnd}}_merged_rows(id);
analyze pr_appr_{{rnd}}_merged_rows;

create temp table pr_appr_{{rnd}}_open_rows as
select distinct
  id,
  event_id
from
  pr_appr_{{rnd}}_ip
where
  closed_at is null
;
create index on pr_appr_{{rnd}}_open_rows(event_id);
create index on pr_appr_{{rnd}}_open_rows(id);
analyze pr_appr_{{rnd}}_open_rows;

create temp table pr_appr_{{rnd}}_merged_events_with_comments as
select distinct
  c.event_id
from
  gha_comments c
join
  pr_appr_{{rnd}}_merged_rows m
on
  m.event_id = c.event_id
;
create unique index on pr_appr_{{rnd}}_merged_events_with_comments(event_id);
analyze pr_appr_{{rnd}}_merged_events_with_comments;

create temp table pr_appr_{{rnd}}_approved_merged as
select distinct
  m.id
from
  pr_appr_{{rnd}}_merged_rows m
join
  pr_appr_{{rnd}}_merged_events_with_comments e
on
  e.event_id = m.event_id
;
create unique index on pr_appr_{{rnd}}_approved_merged(id);
analyze pr_appr_{{rnd}}_approved_merged;

create temp table pr_appr_{{rnd}}_open_events_with_approval as
select distinct
  c.event_id
from
  gha_comments c
join
  pr_appr_{{rnd}}_open_rows o
on
  o.event_id = c.event_id
where
  (
    c.body ilike '%/approve%'
    or c.body ilike '%/lgtm%'
  )
  and substring(c.body from '(?i)(?:^|\n|\r)\s*/(approve|lgtm)\s*(?:\n|\r|$)') is not null
;
create unique index on pr_appr_{{rnd}}_open_events_with_approval(event_id);
analyze pr_appr_{{rnd}}_open_events_with_approval;

create temp table pr_appr_{{rnd}}_approved_open as
select distinct
  o.id
from
  pr_appr_{{rnd}}_open_rows o
join
  pr_appr_{{rnd}}_open_events_with_approval e
on
  e.event_id = o.event_id
;
create unique index on pr_appr_{{rnd}}_approved_open(id);
analyze pr_appr_{{rnd}}_approved_open;

create temp table approved_prs_{{rnd}} as
select id from pr_appr_{{rnd}}_approved_merged
union
select id from pr_appr_{{rnd}}_approved_open
;
create unique index on approved_prs_{{rnd}}(id);
analyze approved_prs_{{rnd}};

create temp table all_prs_groups_{{rnd}} as
select distinct
  r.repo_group,
  p.id
from
  all_prs_{{rnd}} p
join
  gha_repo_groups r
on
  r.id = p.dup_repo_id
  and r.name = p.dup_repo_name
where
  r.repo_group is not null
  and r.repo_group in (select all_repo_group_name from tall_repo_groups)
;
create index on all_prs_groups_{{rnd}}(repo_group);
create index on all_prs_groups_{{rnd}}(id);
create index on all_prs_groups_{{rnd}}(repo_group, id);
analyze all_prs_groups_{{rnd}};

select
  'pr_appr;All;appr,wait' as name,
  round(count(distinct p.id) filter (where a.id is not null) / {{n}}, 2) as approved,
  round(count(distinct p.id) filter (where a.id is null) / {{n}}, 2) as awaiting
from
  all_prs_{{rnd}} p
left join
  approved_prs_{{rnd}} a
on
  p.id = a.id

union all

select
  'pr_appr;' || g.repo_group || ';appr,wait' as name,
  round(count(distinct g.id) filter (where a.id is not null) / {{n}}, 2) as approved,
  round(count(distinct g.id) filter (where a.id is null) / {{n}}, 2) as awaiting
from
  all_prs_groups_{{rnd}} g
left join
  approved_prs_{{rnd}} a
on
  g.id = a.id
group by
  g.repo_group

order by
  approved desc,
  awaiting desc,
  name asc
;

