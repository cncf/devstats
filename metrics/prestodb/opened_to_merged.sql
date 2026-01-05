create temp table open2merge_ids_{{rnd}} as
select distinct pr.id
from gha_pull_requests pr
where
  pr.created_at >= '{{from}}'
  and pr.created_at < '{{to}}'
  and pr.merged_at is not null
;
create unique index on open2merge_ids_{{rnd}}(id);
analyze open2merge_ids_{{rnd}};

create temp table open2merge_latest_prs_{{rnd}} as
select
  x.id,
  x.user_id,
  x.dup_repo_id,
  x.dup_repo_name,
  x.created_at,
  x.merged_at,
  (extract(epoch from x.merged_at - x.created_at) / 3600.0) as open_to_merge
from open2merge_ids_{{rnd}} ids
join lateral (
  select
    pr.id,
    pr.user_id,
    pr.dup_repo_id,
    pr.dup_repo_name,
    pr.created_at,
    pr.merged_at
  from gha_pull_requests pr
  where pr.id = ids.id
  order by pr.updated_at desc
  limit 1
) x on true
where
  x.merged_at is not null
  and x.created_at >= '{{from}}'
  and x.created_at < '{{to}}'
;
create index on open2merge_latest_prs_{{rnd}}(dup_repo_id, dup_repo_name);
create index on open2merge_latest_prs_{{rnd}}(user_id, created_at);
analyze open2merge_latest_prs_{{rnd}};

create temp table open2merge_repo_groups_{{rnd}} as
select id, name, repo_group
from gha_repo_groups
where repo_group is not null
;
create index on open2merge_repo_groups_{{rnd}}(id, name);
create index on open2merge_repo_groups_{{rnd}}(repo_group);
analyze open2merge_repo_groups_{{rnd}};

create temp table open2merge_companies_{{rnd}} as
select distinct companies_name as company_name
from tcompanies
;
create unique index on open2merge_companies_{{rnd}}(company_name);
analyze open2merge_companies_{{rnd}};

create temp table open2merge_actor_ids_{{rnd}} as
select distinct user_id as actor_id
from open2merge_latest_prs_{{rnd}}
where user_id is not null
;
create unique index on open2merge_actor_ids_{{rnd}}(actor_id);
analyze open2merge_actor_ids_{{rnd}};

create temp table open2merge_aff_{{rnd}} as
select
  aa.actor_id,
  aa.company_name,
  aa.dt_from,
  aa.dt_to
from gha_actors_affiliations aa
join open2merge_actor_ids_{{rnd}} a
  on a.actor_id = aa.actor_id
join open2merge_companies_{{rnd}} c
  on c.company_name = aa.company_name
where
  aa.dt_to > '{{from}}'
  and aa.dt_from < '{{to}}'
;
create index on open2merge_aff_{{rnd}}(actor_id, dt_from, dt_to);
create index on open2merge_aff_{{rnd}}(company_name);
analyze open2merge_aff_{{rnd}};

create temp table open2merge_prs_groups_{{rnd}} as
select
  rg.repo_group,
  p.open_to_merge
from open2merge_latest_prs_{{rnd}} p
join open2merge_repo_groups_{{rnd}} rg
  on rg.id = p.dup_repo_id
 and rg.name = p.dup_repo_name
where
  rg.repo_group is not null
;
create index on open2merge_prs_groups_{{rnd}}(repo_group);
analyze open2merge_prs_groups_{{rnd}};

create temp table open2merge_prs_comps_{{rnd}} as
select
  a.company_name,
  p.dup_repo_id,
  p.dup_repo_name,
  p.open_to_merge
from open2merge_latest_prs_{{rnd}} p
join open2merge_aff_{{rnd}} a
  on a.actor_id = p.user_id
 and a.dt_from <= p.created_at
 and a.dt_to > p.created_at
;
create index on open2merge_prs_comps_{{rnd}}(company_name);
create index on open2merge_prs_comps_{{rnd}}(dup_repo_id, dup_repo_name);
analyze open2merge_prs_comps_{{rnd}};

create temp table open2merge_prs_groups_comps_{{rnd}} as
select
  rg.repo_group,
  pc.company_name,
  pc.open_to_merge
from open2merge_prs_comps_{{rnd}} pc
join open2merge_repo_groups_{{rnd}} rg
  on rg.id = pc.dup_repo_id
 and rg.name = pc.dup_repo_name
where
  rg.repo_group is not null
;
create index on open2merge_prs_groups_comps_{{rnd}}(repo_group, company_name);
analyze open2merge_prs_groups_comps_{{rnd}};

select
  'open2merge;All_All;p15,med,p85' as name,
  (pcts)[1] as open_to_merge_15_percentile,
  (pcts)[2] as open_to_merge_median,
  (pcts)[3] as open_to_merge_85_percentile
from (
  select percentile_disc(array[0.15, 0.5, 0.85]) within group (order by open_to_merge asc) as pcts
  from open2merge_latest_prs_{{rnd}}
) all_all

union
select
  'open2merge;' || repo_group || '_All;p15,med,p85' as name,
  (pcts)[1] as open_to_merge_15_percentile,
  (pcts)[2] as open_to_merge_median,
  (pcts)[3] as open_to_merge_85_percentile
from (
  select
    repo_group,
    percentile_disc(array[0.15, 0.5, 0.85]) within group (order by open_to_merge asc) as pcts
  from open2merge_prs_groups_{{rnd}}
  group by repo_group
) g

union
select
  'open2merge;All_' || company_name || ';p15,med,p85' as name,
  (pcts)[1] as open_to_merge_15_percentile,
  (pcts)[2] as open_to_merge_median,
  (pcts)[3] as open_to_merge_85_percentile
from (
  select
    company_name,
    percentile_disc(array[0.15, 0.5, 0.85]) within group (order by open_to_merge asc) as pcts
  from open2merge_prs_comps_{{rnd}}
  group by company_name
) c

union
select
  'open2merge;' || repo_group || '_' || company_name || ';p15,med,p85' as name,
  (pcts)[1] as open_to_merge_15_percentile,
  (pcts)[2] as open_to_merge_median,
  (pcts)[3] as open_to_merge_85_percentile
from (
  select
    repo_group,
    company_name,
    percentile_disc(array[0.15, 0.5, 0.85]) within group (order by open_to_merge asc) as pcts
  from open2merge_prs_groups_comps_{{rnd}}
  group by repo_group, company_name
) gc

order by
  open_to_merge_median desc,
  name asc
;

