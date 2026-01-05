create temp table iage_ids_{{rnd}} as
select distinct
  i.id
from
  gha_issues i
join
  gha_repo_groups r
on
  r.id = i.dup_repo_id
  and r.name = i.dup_repo_name
where
  i.is_pull_request = false
  and i.closed_at is not null
  and i.created_at >= '{{from}}'
  and i.created_at < '{{to}}'
;
create unique index on iage_ids_{{rnd}}(id);
analyze iage_ids_{{rnd}};

create temp table iage_latest_{{rnd}} as
select
  x.id,
  x.dup_repo_id,
  x.dup_repo_name,
  x.created_at,
  x.closed_at
from
  iage_ids_{{rnd}} ids
join lateral (
  select
    n.id,
    n.dup_repo_id,
    n.dup_repo_name,
    n.created_at,
    n.closed_at,
    n.is_pull_request
  from
    gha_issues n
  where
    n.id = ids.id
  order by
    n.updated_at desc
  limit 1
) x on true
where
  x.is_pull_request = false
  and x.closed_at is not null
  and x.created_at >= '{{from}}'
  and x.created_at < '{{to}}'
;
create unique index on iage_latest_{{rnd}}(id);
create index on iage_latest_{{rnd}}(dup_repo_id, dup_repo_name);
analyze iage_latest_{{rnd}};

create temp table iage_tdiffs_{{rnd}} as
select
  i.id,
  r.repo_group,
  extract(epoch from i.closed_at - i.created_at) / 3600.0 as age
from
  iage_latest_{{rnd}} i
join
  gha_repo_groups r
on
  r.id = i.dup_repo_id
  and r.name = i.dup_repo_name
;
create index on iage_tdiffs_{{rnd}}(id);
create index on iage_tdiffs_{{rnd}}(repo_group);
analyze iage_tdiffs_{{rnd}};

create temp table iage_labels_{{rnd}} as
select distinct
  l.issue_id,
  l.dup_label_name as name
from
  gha_issues_labels l
join
  iage_latest_{{rnd}} i
on
  i.id = l.issue_id
where
  l.dup_created_at >= '{{from}}'
  and l.dup_created_at < '{{to}}'
  and l.dup_label_name like 'priority/%'
;
create index on iage_labels_{{rnd}}(issue_id);
create index on iage_labels_{{rnd}}(name);
analyze iage_labels_{{rnd}};

select
  'iage;All_All;n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
union
select
  'iage;' || t.repo_group || '_All;n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
where
  t.repo_group is not null
group by
  t.repo_group
union
select
  'iage;All_' || substring(prio.name from 10) || ';n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
join
  iage_labels_{{rnd}} prio
on
  prio.issue_id = t.id
where
  prio.name like 'priority/%'
group by
  prio.name
union
select
  'iage;' || t.repo_group || '_' || substring(prio.name from 10) || ';n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
join
  iage_labels_{{rnd}} prio
on
  prio.issue_id = t.id
where
  t.repo_group is not null
  and prio.name like 'priority/%'
group by
  t.repo_group,
  prio.name
order by
  age_median asc,
  name asc
;

