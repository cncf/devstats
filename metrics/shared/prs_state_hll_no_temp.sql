with all_prs as (
  select distinct i.id,
    i.dup_repo_name,
    i.dup_repo_id
  from
    gha_issues i,
    gha_issues_pull_requests ipr,
    gha_pull_requests pr
  where
    ipr.issue_id = i.id
    and ipr.pull_request_id = pr.id
    and i.number = pr.number
    and i.number = ipr.number
    and pr.number = ipr.number
    and i.dup_repo_id = pr.dup_repo_id
    and i.dup_repo_name = pr.dup_repo_name
    and pr.dup_repo_id = ipr.repo_id
    and pr.dup_repo_name = ipr.repo_name
    and i.is_pull_request = true
    and pr.updated_at >= '{{from}}'
    and pr.updated_at < '{{to}}'
    and i.updated_at >= '{{from}}'
    and i.updated_at < '{{to}}'
    and (
      pr.merged_at is not null
      or pr.closed_at is null
    )
), approved_prs as (
  select distinct i.id
  from
    gha_issues i,
    gha_comments c,
    gha_issues_pull_requests ipr,
    gha_pull_requests pr
  where
    ipr.issue_id = i.id
    and ipr.pull_request_id = pr.id
    and i.number = pr.number
    and i.number = ipr.number
    and pr.number = ipr.number
    and i.dup_repo_id = pr.dup_repo_id
    and i.dup_repo_name = pr.dup_repo_name
    and pr.dup_repo_id = ipr.repo_id
    and pr.dup_repo_name = ipr.repo_name
    and i.event_id = c.event_id
    and i.is_pull_request = true
    and pr.updated_at >= '{{from}}'
    and pr.updated_at < '{{to}}'
    and i.updated_at >= '{{from}}'
    and i.updated_at < '{{to}}'
    and (
      pr.merged_at is not null
      or (
        pr.closed_at is null
        and substring(c.body from '(?i)(?:^|\n|\r)\s*/(approve|lgtm)\s*(?:\n|\r|$)') is not null
    )
  )
)
select
  'pr_appr;All;appr,wait' as name,
  round((hll_cardinality(hll_add_agg(hll_hash_bigint(case a.id is not null when true then prs.id end))) / {{n}})::numeric, 2) as approved,
  round((hll_cardinality(hll_add_agg(hll_hash_bigint(case a.id is null when true then prs.id end))) / {{n}})::numeric, 2) as awaiting
from
  all_prs prs
left join 
  approved_prs a
on
  prs.id = a.id
union select 'pr_appr;' || r.repo_group ||';appr,wait' as name,
  round((hll_cardinality(hll_add_agg(hll_hash_bigint(case a.id is not null when true then prs.id end))) / {{n}})::numeric, 2) as approved,
  round((hll_cardinality(hll_add_agg(hll_hash_bigint(case a.id is null when true then prs.id end))) / {{n}})::numeric, 2) as awaiting
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
