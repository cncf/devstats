create temp table open2merge_ids_{{rnd}} as
select distinct
  pr.id
from
  gha_pull_requests pr
where
  pr.created_at >= '{{from}}'
  and pr.created_at < '{{to}}'
  and pr.merged_at is not null
;
create unique index on open2merge_ids_{{rnd}}(id);
analyze open2merge_ids_{{rnd}};

create temp table open2merge_prs_{{rnd}} as
select
  x.created_at,
  x.merged_at,
  x.dup_repo_id,
  x.dup_repo_name,
  (extract(epoch from x.merged_at - x.created_at) / 3600.0) as open_to_merge
from
  open2merge_ids_{{rnd}} ids
join lateral (
  select
    pr.created_at,
    pr.merged_at,
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
  x.merged_at is not null
  and x.created_at >= '{{from}}'
  and x.created_at < '{{to}}'
;
create index on open2merge_prs_{{rnd}}(dup_repo_id, dup_repo_name);
analyze open2merge_prs_{{rnd}};

create temp table open2merge_repo_groups_{{rnd}} as
select
  id,
  name,
  repo_group
from
  gha_repo_groups
where
  repo_group is not null
;
create index on open2merge_repo_groups_{{rnd}}(id, name);
create index on open2merge_repo_groups_{{rnd}}(repo_group);
analyze open2merge_repo_groups_{{rnd}};

create temp table open2merge_prs_groups_{{rnd}} as
select
  rg.repo_group,
  p.open_to_merge
from
  open2merge_prs_{{rnd}} p
join
  open2merge_repo_groups_{{rnd}} rg
on
  rg.id = p.dup_repo_id
  and rg.name = p.dup_repo_name
where
  rg.repo_group is not null
;
create index on open2merge_prs_groups_{{rnd}}(repo_group, open_to_merge);
analyze open2merge_prs_groups_{{rnd}};

select
  'open2merge;All;p15,med,p85' as name,
  (pcts)[1] as open_to_merge_15_percentile,
  (pcts)[2] as open_to_merge_median,
  (pcts)[3] as open_to_merge_85_percentile
from (
  select
    percentile_disc(array[0.15, 0.5, 0.85]) within group (order by open_to_merge asc) as pcts
  from
    open2merge_prs_{{rnd}}
) a

union

select
  'open2merge;' || repo_group || ';p15,med,p85' as name,
  (pcts)[1] as open_to_merge_15_percentile,
  (pcts)[2] as open_to_merge_median,
  (pcts)[3] as open_to_merge_85_percentile
from (
  select
    repo_group,
    percentile_disc(array[0.15, 0.5, 0.85]) within group (order by open_to_merge asc) as pcts
  from
    open2merge_prs_groups_{{rnd}}
  group by
    repo_group
) g
order by
  open_to_merge_median desc,
  name asc
;

