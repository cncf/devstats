create temp table trepos_{{rnd}} as
select distinct
  repo_name
from
  trepos
;
create unique index on trepos_{{rnd}}(repo_name);
analyze trepos_{{rnd}};

create temp table pr_issues_latest_{{rnd}} as
select distinct on (i.id)
  i.id,
  i.number,
  i.dup_repo_name,
  i.dup_repo_id
from
  gha_issues i
where
  i.is_pull_request = true
  and i.updated_at >= '{{from}}'
  and i.updated_at < '{{to}}'
order by
  i.id,
  i.updated_at desc,
  i.event_id desc
;
create unique index on pr_issues_latest_{{rnd}}(id);
create index on pr_issues_latest_{{rnd}}(dup_repo_name);
create index on pr_issues_latest_{{rnd}}(dup_repo_id);
create index on pr_issues_latest_{{rnd}}(number);
analyze pr_issues_latest_{{rnd}};

create temp table pr_snap_{{rnd}} as
select
  pr.id as pull_request_id,
  pr.number,
  pr.dup_repo_id,
  pr.dup_repo_name,
  pr.merged_at,
  pr.closed_at
from
  gha_pull_requests pr
where
  pr.updated_at >= '{{from}}'
  and pr.updated_at < '{{to}}'
;
create index on pr_snap_{{rnd}}(pull_request_id);
create index on pr_snap_{{rnd}}(dup_repo_id, dup_repo_name, number, pull_request_id);
analyze pr_snap_{{rnd}};

create temp table ipr_{{rnd}} as
select distinct
  ipr.issue_id,
  ipr.pull_request_id,
  ipr.repo_id,
  ipr.repo_name,
  ipr.number
from
  gha_issues_pull_requests ipr
join
  pr_issues_latest_{{rnd}} i
on
  i.id = ipr.issue_id
  and i.number = ipr.number
  and i.dup_repo_id = ipr.repo_id
  and i.dup_repo_name = ipr.repo_name
;
create index on ipr_{{rnd}}(issue_id);
create index on ipr_{{rnd}}(pull_request_id);
create index on ipr_{{rnd}}(repo_id, repo_name, number, pull_request_id);
analyze ipr_{{rnd}};

create temp table pr_flags_{{rnd}} as
select
  ipr.issue_id,
  ipr.repo_id,
  ipr.repo_name,
  ipr.number,
  bool_or(ps.merged_at is not null) as merged_any,
  bool_or(ps.closed_at is null) as open_any
from
  ipr_{{rnd}} ipr
join
  pr_snap_{{rnd}} ps
on
  ps.pull_request_id = ipr.pull_request_id
  and ps.number = ipr.number
  and ps.dup_repo_id = ipr.repo_id
  and ps.dup_repo_name = ipr.repo_name
group by
  ipr.issue_id,
  ipr.repo_id,
  ipr.repo_name,
  ipr.number
;
create unique index on pr_flags_{{rnd}}(issue_id, repo_id, repo_name, number);
create index on pr_flags_{{rnd}}(repo_name);
analyze pr_flags_{{rnd}};

create temp table all_prs_{{rnd}} as
select
  i.id,
  i.dup_repo_name,
  i.dup_repo_id
from
  pr_issues_latest_{{rnd}} i
join
  pr_flags_{{rnd}} pf
on
  pf.issue_id = i.id
  and pf.repo_id = i.dup_repo_id
  and pf.repo_name = i.dup_repo_name
  and pf.number = i.number
where
  pf.merged_any
  or pf.open_any
;
create unique index on all_prs_{{rnd}}(id);
create index on all_prs_{{rnd}}(dup_repo_name);
create index on all_prs_{{rnd}}(dup_repo_id);
analyze all_prs_{{rnd}};

create temp table issue_events_{{rnd}} as
select
  i.id,
  i.event_id,
  i.number,
  i.dup_repo_id,
  i.dup_repo_name
from
  gha_issues i
join
  all_prs_{{rnd}} ap
on
  ap.id = i.id
where
  i.is_pull_request = true
  and i.updated_at >= '{{from}}'
  and i.updated_at < '{{to}}'
;
create index on issue_events_{{rnd}}(event_id);
create index on issue_events_{{rnd}}(id);
create index on issue_events_{{rnd}}(id, dup_repo_id, dup_repo_name, number);
analyze issue_events_{{rnd}};

create temp table approved_prs_{{rnd}} as
select distinct
  ie.id
from
  issue_events_{{rnd}} ie
join
  pr_flags_{{rnd}} pf
on
  pf.issue_id = ie.id
  and pf.repo_id = ie.dup_repo_id
  and pf.repo_name = ie.dup_repo_name
  and pf.number = ie.number
join
  gha_comments c
on
  c.event_id = ie.event_id
where
  pf.merged_any
  or (
    pf.open_any
    and (
      (c.body ilike '%/approve%' or c.body ilike '%/lgtm%')
      and substring(c.body from '(?i)(?:^|\n|\r)\s*/(approve|lgtm)\s*(?:\n|\r|$)') is not null
    )
  )
;
create unique index on approved_prs_{{rnd}}(id);
analyze approved_prs_{{rnd}};

create temp table pr_status_{{rnd}} as
select
  ap.id,
  ap.dup_repo_name,
  (a.id is not null) as is_approved
from
  all_prs_{{rnd}} ap
left join
  approved_prs_{{rnd}} a
on
  a.id = ap.id
;
create unique index on pr_status_{{rnd}}(id);
create index on pr_status_{{rnd}}(dup_repo_name);
analyze pr_status_{{rnd}};

select
  name,
  approved,
  awaiting
from (
  select
    'pr_repappr;All;appr,wait' as name,
    round(count(*) filter (where is_approved)::numeric / {{n}}, 2) as approved,
    round(count(*) filter (where not is_approved)::numeric / {{n}}, 2) as awaiting
  from
    pr_status_{{rnd}}

  union
  select
    'pr_repappr;' || ps.dup_repo_name || ';appr,wait' as name,
    round(count(*) filter (where ps.is_approved)::numeric / {{n}}, 2) as approved,
    round(count(*) filter (where not ps.is_approved)::numeric / {{n}}, 2) as awaiting
  from
    pr_status_{{rnd}} ps
  join
    trepos_{{rnd}} tr
  on
    tr.repo_name = ps.dup_repo_name
  group by
    ps.dup_repo_name
) final
order by
  approved desc,
  awaiting desc,
  name asc
;

