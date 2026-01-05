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
    x.created_at,
    x.merged_at,
    x.closed_at,
    x.dup_repo_id,
    x.dup_repo_name,
    extract(epoch from coalesce(x.merged_at - x.created_at, now() - x.created_at)) / 3600.0 as age
  from
    pr_ids ids
  join lateral (
    select
      pr.id,
      pr.created_at,
      pr.merged_at,
      pr.closed_at,
      pr.dup_repo_id,
      pr.dup_repo_name
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
    and (
      x.closed_at is null
      or (
        x.closed_at is not null
        and x.merged_at is not null
      )
    )
), prs_groups as (
  select
    r.repo_group,
    p.id,
    p.age
  from
    prs p
  join
    gha_repo_groups r
  on
    r.id = p.dup_repo_id
    and r.name = p.dup_repo_name
  where
    r.repo_group is not null
)
select
  'prs_age;All;n,m' as name,
  round((hll_cardinality(hll_add_agg(hll_hash_bigint(id))) / {{n}})::numeric, 2) as num,
  percentile_disc(0.5) within group (order by age asc) as age_median
from
  prs
union
select
  'prs_age;' || repo_group || ';n,m' as name,
  round((hll_cardinality(hll_add_agg(hll_hash_bigint(id))) / {{n}})::numeric, 2) as num,
  percentile_disc(0.5) within group (order by age asc) as age_median
from
  prs_groups
group by
  repo_group
order by
  num desc,
  name asc
;

