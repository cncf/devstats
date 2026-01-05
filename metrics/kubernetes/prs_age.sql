with pr_ids as (
  select distinct
    pr.id
  from
    gha_pull_requests pr
  where
    pr.created_at >= '{{from}}'
    and pr.created_at < '{{to}}'
), prs as (
  select
    x.id,
    x.dup_repo_id as repo_id,
    x.dup_repo_name as repo_name,
    x.created_at,
    x.merged_at,
    x.event_id,
    extract(epoch from coalesce(x.merged_at - x.created_at, now() - x.created_at)) / 3600.0 as age
  from
    pr_ids ids
  join lateral (
    select
      pr.id,
      pr.dup_repo_id,
      pr.dup_repo_name,
      pr.created_at,
      pr.merged_at,
      pr.event_id
    from
      gha_pull_requests pr
    where
      pr.id = ids.id
    order by
      pr.updated_at desc
    limit 1
  ) x on true
  where
    x.created_at >= '{{from}}'
    and x.created_at < '{{to}}'
), prs_event_repo_groups as (
  select distinct
    ecf.event_id,
    ecf.repo_group
  from
    gha_events_commits_files ecf
  join (
    select distinct
      event_id
    from
      prs
  ) pe
  on
    pe.event_id = ecf.event_id
), ipr as (
  select distinct
    issue_id,
    pull_request_id,
    repo_id,
    repo_name
  from
    gha_issues_pull_requests
  where
    created_at >= '{{from}}'
    and created_at < '{{to}}'
), iel as (
  select distinct
    issue_id,
    label_name
  from
    gha_issues_events_labels
  where
    label_name in (
      'kind/api-change', 'kind/bug', 'kind/feature', 'kind/design',
      'kind/cleanup', 'kind/documentation', 'kind/flake', 'kind/kep'
    )
    and created_at >= '{{from}}'
    and created_at < '{{to}}'
), prs_labels as (
  select distinct
    pr.id,
    pr.repo_id,
    pr.repo_name,
    iel.label_name,
    pr.created_at,
    pr.merged_at,
    pr.event_id as pr_event_id,
    pr.age
  from
    prs pr
  join
    ipr
  on
    pr.id = ipr.pull_request_id
    and pr.repo_id = ipr.repo_id
    and pr.repo_name = ipr.repo_name
  join
    iel
  on
    iel.issue_id = ipr.issue_id
), prs_groups as (
  select distinct
    coalesce(ecf.repo_group, r.repo_group) as repo_group,
    pr.id,
    pr.age
  from
    prs pr
  join
    gha_repos r
  on
    r.id = pr.repo_id
    and r.name = pr.repo_name
  left join
    prs_event_repo_groups ecf
  on
    ecf.event_id = pr.event_id
  where
    coalesce(ecf.repo_group, r.repo_group) is not null
), prs_groups_labels as (
  select distinct
    coalesce(ecf.repo_group, r.repo_group) as repo_group,
    pl.label_name,
    pl.id,
    pl.age
  from
    prs_labels pl
  join
    gha_repos r
  on
    r.id = pl.repo_id
    and r.name = pl.repo_name
  left join
    prs_event_repo_groups ecf
  on
    ecf.event_id = pl.pr_event_id
  where
    coalesce(ecf.repo_group, r.repo_group) is not null
)
select
  'prs_age;All,All;n,m' as name,
  round(count(distinct id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by age asc) as age_median
from
  prs
union
select
  'prs_age;' || repo_group || ',All;n,m' as name,
  round(count(distinct id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by age asc) as age_median
from
  prs_groups
group by
  repo_group
union
select
  'prs_age;All,' || substring(label_name from 6) || ';n,m' as name,
  round(count(distinct id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by age asc) as age_median
from
  prs_labels
group by
  substring(label_name from 6)
union
select
  'prs_age;' || repo_group || ',' || substring(label_name from 6) || ';n,m' as name,
  round(count(distinct id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by age asc) as age_median
from
  prs_groups_labels
group by
  repo_group,
  substring(label_name from 6)
order by
  num desc,
  name asc
;

