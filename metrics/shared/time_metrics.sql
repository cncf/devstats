with prs_latest as (
  select distinct on (pr.id)
    pr.created_at,
    pr.merged_at,
    pr.dup_repo_id,
    pr.dup_repo_name
  from
    gha_pull_requests pr
  where
    pr.created_at >= '{{from}}'
    and pr.created_at < '{{to}}'
    and pr.merged_at is not null
  order by
    pr.id,
    pr.updated_at desc,
    pr.event_id desc
), tdiffs as (
  select
    extract(epoch from (pr.merged_at - pr.created_at)) / 3600 as open_to_merge,
    r.repo_group
  from
    prs_latest pr
  left join
    gha_repo_groups r
  on
    r.id = pr.dup_repo_id
    and r.name = pr.dup_repo_name
    and r.repo_group is not null
)
select
  case
    when grouping(repo_group) = 1 then 'tmet;All;med,p85'
    else 'tmet;' || repo_group || ';med,p85'
  end as name,
  greatest(percentile_disc(0.5) within group (order by open_to_merge asc), 0) as m_o2m,
  greatest(percentile_disc(0.85) within group (order by open_to_merge asc), 0) as pc_o2m
from
  tdiffs
group by
  grouping sets ((repo_group), ())
having
  grouping(repo_group) = 1
  or repo_group is not null
order by
  name asc
;

