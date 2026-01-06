with const as (
  select
    'amedo2l,amedl2a,ameda2m,ap85o2l,ap85l2a,ap85a2m,ymedo2l,ymedl2a,ymeda2m,yp85o2l,yp85l2a,yp85a2m,nmedo2l,nmedl2a,nmeda2m,np85o2l,np85l2a,np85a2m'::text as s
), prs_latest as materialized (
  select distinct on (pr.id)
    pr.id,
    pr.event_id,
    pr.created_at,
    pr.merged_at,
    pr.dup_repo_id,
    pr.dup_repo_name
  from
    gha_pull_requests pr
  join
    trepos tr
  on
    tr.repo_name = pr.dup_repo_name
  where
    pr.created_at >= '{{from}}'
    and pr.created_at < '{{to}}'
    and pr.merged_at is not null
  order by
    pr.id,
    pr.updated_at desc,
    pr.event_id desc
), prs_ipr as materialized (
  select
    pr.id as pr_id,
    pr.event_id,
    pr.created_at,
    pr.merged_at,
    pr.dup_repo_id,
    pr.dup_repo_name as repo,
    ipr.issue_id
  from
    prs_latest pr
  join
    gha_issues_pull_requests ipr
  on
    ipr.pull_request_id = pr.id
    and ipr.repo_id = pr.dup_repo_id
    and ipr.repo_name = pr.dup_repo_name
), issues_set as materialized (
  select distinct
    issue_id
  from
    prs_ipr
), api_change_lbl as materialized (
  select distinct
    l.issue_id
  from
    gha_issues_events_labels l
  join
    issues_set s
  on
    s.issue_id = l.issue_id
  where
    l.label_name = 'kind/api-change'
), prs as materialized (
  select distinct
    p.issue_id,
    p.repo,
    p.created_at,
    p.merged_at,
    case when ac.issue_id is null then 'no' else 'yes' end as api_change
  from
    prs_ipr p
  left join
    api_change_lbl ac
  on
    ac.issue_id = p.issue_id
), issue_times as materialized (
  select
    l.issue_id,
    min(l.created_at) filter (where l.label_name = 'lgtm') as lgtm_at,
    min(l.created_at) filter (where l.label_name = 'approved') as approve_at
  from
    gha_issues_events_labels l
  join
    issues_set s
  on
    s.issue_id = l.issue_id
  where
    l.label_name in ('lgtm', 'approved')
  group by
    l.issue_id
), tdiffs as materialized (
  select
    p.issue_id,
    p.repo,
    p.api_change,
    extract(epoch from coalesce(t.lgtm_at - p.created_at, t.approve_at - p.created_at, p.merged_at - p.created_at)) / 3600 as open_to_lgtm,
    extract(epoch from coalesce(t.approve_at - t.lgtm_at, p.merged_at - t.lgtm_at, interval '0')) / 3600 as lgtm_to_approve,
    extract(epoch from coalesce(p.merged_at - t.approve_at, interval '0')) / 3600 as approve_to_merge
  from
    prs p
  left join
    issue_times t
  on
    t.issue_id = p.issue_id
), labels_all as materialized (
  select distinct
    l.issue_id,
    l.label_name,
    substring(l.label_name from 6) as label_sub_name
  from
    gha_issues_events_labels l
  join
    issues_set s
  on
    s.issue_id = l.issue_id
  where
    l.label_name like 'size/%'
    or l.label_name in (
      'kind/bug', 'kind/feature', 'kind/design', 'kind/cleanup',
      'kind/documentation', 'kind/flake', 'kind/kep'
    )
), size_labels as materialized (
  select
    issue_id,
    label_sub_name as size
  from
    labels_all
  where
    label_name like 'size/%'
), kind_labels as materialized (
  select
    issue_id,
    label_sub_name as kind
  from
    labels_all
  where
    label_name in (
      'kind/bug', 'kind/feature', 'kind/design', 'kind/cleanup',
      'kind/documentation', 'kind/flake', 'kind/kep'
    )
), fact as materialized (
  select
    0 as part,
    null::text as repo,
    null::text as size,
    null::text as kind,
    t.api_change,
    t.open_to_lgtm,
    t.lgtm_to_approve,
    t.approve_to_merge
  from
    tdiffs t
  union all
  select
    1 as part,
    t.repo,
    null::text as size,
    null::text as kind,
    t.api_change,
    t.open_to_lgtm,
    t.lgtm_to_approve,
    t.approve_to_merge
  from
    tdiffs t
  union all
  select
    2 as part,
    null::text as repo,
    s.size,
    null::text as kind,
    t.api_change,
    t.open_to_lgtm,
    t.lgtm_to_approve,
    t.approve_to_merge
  from
    tdiffs t
  join
    size_labels s
  on
    s.issue_id = t.issue_id
  union all
  select
    3 as part,
    t.repo,
    s.size,
    null::text as kind,
    t.api_change,
    t.open_to_lgtm,
    t.lgtm_to_approve,
    t.approve_to_merge
  from
    tdiffs t
  join
    size_labels s
  on
    s.issue_id = t.issue_id
  union all
  select
    4 as part,
    null::text as repo,
    null::text as size,
    k.kind,
    t.api_change,
    t.open_to_lgtm,
    t.lgtm_to_approve,
    t.approve_to_merge
  from
    tdiffs t
  join
    kind_labels k
  on
    k.issue_id = t.issue_id
  union all
  select
    5 as part,
    t.repo,
    null::text as size,
    k.kind,
    t.api_change,
    t.open_to_lgtm,
    t.lgtm_to_approve,
    t.approve_to_merge
  from
    tdiffs t
  join
    kind_labels k
  on
    k.issue_id = t.issue_id
  union all
  select
    6 as part,
    null::text as repo,
    s.size,
    k.kind,
    t.api_change,
    t.open_to_lgtm,
    t.lgtm_to_approve,
    t.approve_to_merge
  from
    tdiffs t
  join
    size_labels s
  on
    s.issue_id = t.issue_id
  join
    kind_labels k
  on
    k.issue_id = t.issue_id
  union all
  select
    7 as part,
    t.repo,
    s.size,
    k.kind,
    t.api_change,
    t.open_to_lgtm,
    t.lgtm_to_approve,
    t.approve_to_merge
  from
    tdiffs t
  join
    size_labels s
  on
    s.issue_id = t.issue_id
  join
    kind_labels k
  on
    k.issue_id = t.issue_id
), agg as (
  select
    f.part,
    f.repo,
    f.size,
    f.kind,
    greatest(percentile_disc(0.5) within group (order by f.open_to_lgtm asc), 0) as m_o2l_a,
    greatest(percentile_disc(0.5) within group (order by f.lgtm_to_approve asc), 0) as m_l2a_a,
    greatest(percentile_disc(0.5) within group (order by f.approve_to_merge asc), 0) as m_a2m_a,
    greatest(percentile_disc(0.85) within group (order by f.open_to_lgtm asc), 0) as pc_o2l_a,
    greatest(percentile_disc(0.85) within group (order by f.lgtm_to_approve asc), 0) as pc_l2a_a,
    greatest(percentile_disc(0.85) within group (order by f.approve_to_merge asc), 0) as pc_a2m_a,
    greatest(percentile_disc(0.5) within group (order by f.open_to_lgtm asc) filter (where f.api_change = 'yes'), 0) as m_o2l_y,
    greatest(percentile_disc(0.5) within group (order by f.lgtm_to_approve asc) filter (where f.api_change = 'yes'), 0) as m_l2a_y,
    greatest(percentile_disc(0.5) within group (order by f.approve_to_merge asc) filter (where f.api_change = 'yes'), 0) as m_a2m_y,
    greatest(percentile_disc(0.85) within group (order by f.open_to_lgtm asc) filter (where f.api_change = 'yes'), 0) as pc_o2l_y,
    greatest(percentile_disc(0.85) within group (order by f.lgtm_to_approve asc) filter (where f.api_change = 'yes'), 0) as pc_l2a_y,
    greatest(percentile_disc(0.85) within group (order by f.approve_to_merge asc) filter (where f.api_change = 'yes'), 0) as pc_a2m_y,
    greatest(percentile_disc(0.5) within group (order by f.open_to_lgtm asc) filter (where f.api_change = 'no'), 0) as m_o2l_n,
    greatest(percentile_disc(0.5) within group (order by f.lgtm_to_approve asc) filter (where f.api_change = 'no'), 0) as m_l2a_n,
    greatest(percentile_disc(0.5) within group (order by f.approve_to_merge asc) filter (where f.api_change = 'no'), 0) as m_a2m_n,
    greatest(percentile_disc(0.85) within group (order by f.open_to_lgtm asc) filter (where f.api_change = 'no'), 0) as pc_o2l_n,
    greatest(percentile_disc(0.85) within group (order by f.lgtm_to_approve asc) filter (where f.api_change = 'no'), 0) as pc_l2a_n,
    greatest(percentile_disc(0.85) within group (order by f.approve_to_merge asc) filter (where f.api_change = 'no'), 0) as pc_a2m_n
  from
    fact f
  group by
    f.part,
    f.repo,
    f.size,
    f.kind
)
select
  case a.part
    when 0 then 'tmet;All_All_All;' || const.s
    when 1 then 'tmet;' || a.repo || '_All_All;' || const.s
    when 2 then 'tmet;All_' || a.size || '_All;' || const.s
    when 3 then 'tmet;' || a.repo || '_' || a.size || '_All;' || const.s
    when 4 then 'tmet;All_All_' || a.kind || ';' || const.s
    when 5 then 'tmet;' || a.repo || '_All_' || a.kind || ';' || const.s
    when 6 then 'tmet;All_' || a.size || '_' || a.kind || ';' || const.s
    else 'tmet;' || a.repo || '_' || a.size || '_' || a.kind || ';' || const.s
  end as name,
  a.m_o2l_a,
  a.m_l2a_a,
  a.m_a2m_a,
  a.pc_o2l_a,
  a.pc_l2a_a,
  a.pc_a2m_a,
  a.m_o2l_y,
  a.m_l2a_y,
  a.m_a2m_y,
  a.pc_o2l_y,
  a.pc_l2a_y,
  a.pc_a2m_y,
  a.m_o2l_n,
  a.m_l2a_n,
  a.m_a2m_n,
  a.pc_o2l_n,
  a.pc_l2a_n,
  a.pc_a2m_n
from
  agg a
cross join
  const
order by
  name asc
;

