create temp table iage_issue_ids_{{rnd}} as
select distinct
  i.id
from
  gha_issues i
where
  i.is_pull_request = false
  and i.created_at >= '{{from}}'
  and i.created_at < '{{to}}'
  and i.closed_at is not null
;
create unique index on iage_issue_ids_{{rnd}}(id);
analyze iage_issue_ids_{{rnd}};

create temp table iage_latest_{{rnd}} as
select
  x.id,
  x.dup_repo_id,
  x.dup_repo_name,
  x.created_at,
  x.closed_at,
  x.event_id
from
  iage_issue_ids_{{rnd}} ids
join lateral (
  select
    n.id,
    n.dup_repo_id,
    n.dup_repo_name,
    n.created_at,
    n.closed_at,
    n.event_id,
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
create index on iage_latest_{{rnd}}(event_id);
create index on iage_latest_{{rnd}}(dup_repo_id, dup_repo_name);
analyze iage_latest_{{rnd}};

create temp table iage_ecf_{{rnd}} as
select
  ecf.sha,
  ecf.event_id,
  ecf.path,
  ecf.repo_group
from
  gha_events_commits_files ecf
join (
  select distinct
    event_id
  from
    iage_latest_{{rnd}}
) e
on
  e.event_id = ecf.event_id
;
create index on iage_ecf_{{rnd}}(event_id);
analyze iage_ecf_{{rnd}};

create temp table iage_issues_{{rnd}} as
select
  i.id,
  coalesce(ecf.repo_group, r.repo_group) as repo_group,
  i.created_at,
  i.closed_at
from
  iage_latest_{{rnd}} i
join
  gha_repos r
on
  r.id = i.dup_repo_id
  and r.name = i.dup_repo_name
left join
  iage_ecf_{{rnd}} ecf
on
  ecf.event_id = i.event_id
;
create index on iage_issues_{{rnd}}(id);
create index on iage_issues_{{rnd}}(repo_group);
analyze iage_issues_{{rnd}};

create temp table iage_tdiffs_{{rnd}} as
select
  id,
  repo_group,
  extract(epoch from closed_at - created_at) / 3600.0 as age
from
  iage_issues_{{rnd}}
;
create index on iage_tdiffs_{{rnd}}(id);
create index on iage_tdiffs_{{rnd}}(repo_group);
analyze iage_tdiffs_{{rnd}};

create temp table iage_sig_mentions_{{rnd}} as
select distinct
  sig_mentions_labels_name
from
  tsig_mentions_labels
;
create unique index on iage_sig_mentions_{{rnd}}(sig_mentions_labels_name);
analyze iage_sig_mentions_{{rnd}};

create temp table iage_labels_{{rnd}} as
select distinct
  l.issue_id,
  l.mapped_name as name
from (
  select
    il.issue_id,
    il.dup_label_name,
    substring(il.dup_label_name from 5) as sub5,
    case il.dup_label_name
      when 'sig/aws' then 'sig/cloud-provider'
      when 'sig/azure' then 'sig/cloud-provider'
      when 'sig/batchd' then 'sig/cloud-provider'
      when 'sig/cloud-provider-aws' then 'sig/cloud-provider'
      when 'sig/gcp' then 'sig/cloud-provider'
      when 'sig/ibmcloud' then 'sig/cloud-provider'
      when 'sig/openstack' then 'sig/cloud-provider'
      when 'sig/vmware' then 'sig/cloud-provider'
      else il.dup_label_name
    end as mapped_name
  from
    gha_issues_labels il
  where
    il.dup_created_at >= '{{from}}'
    and il.dup_created_at < '{{to}}'
    and (
      il.dup_label_name like 'sig/%'
      or il.dup_label_name like 'kind/%'
      or il.dup_label_name like 'priority/%'
    )
    and il.dup_label_name not like '%use-only-as-a-last-resort'
) l
join
  iage_latest_{{rnd}} i
on
  i.id = l.issue_id
join
  iage_sig_mentions_{{rnd}} sm
on
  sm.sig_mentions_labels_name = l.sub5
where
  l.sub5 not in (
    'apimachinery', 'api-machiner', 'cloude-provider', 'nework',
    'scalability-proprosals', 'storge', 'ui-preview-reviewes',
    'cluster-fifecycle', 'rktnetes'
  )
;
create index on iage_labels_{{rnd}}(issue_id);
create index on iage_labels_{{rnd}}(name);
analyze iage_labels_{{rnd}};

create temp table iage_labels_sig_{{rnd}} as
select
  issue_id,
  name
from
  iage_labels_{{rnd}}
where
  name like 'sig/%'
;
create index on iage_labels_sig_{{rnd}}(issue_id);
create index on iage_labels_sig_{{rnd}}(name);
analyze iage_labels_sig_{{rnd}};

create temp table iage_labels_kind_{{rnd}} as
select
  issue_id,
  name
from
  iage_labels_{{rnd}}
where
  name like 'kind/%'
;
create index on iage_labels_kind_{{rnd}}(issue_id);
create index on iage_labels_kind_{{rnd}}(name);
analyze iage_labels_kind_{{rnd}};

create temp table iage_labels_prio_{{rnd}} as
select
  issue_id,
  name
from
  iage_labels_{{rnd}}
where
  name like 'priority/%'
;
create index on iage_labels_prio_{{rnd}}(issue_id);
create index on iage_labels_prio_{{rnd}}(name);
analyze iage_labels_prio_{{rnd}};

select
  'iage;All_All_All_All;n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t

union
select
  'iage;' || t.repo_group || '_All_All_All;n,m' as name,
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
  'iage;All_' || substring(sig.name from 5) || '_All_All;n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
join
  iage_labels_sig_{{rnd}} sig
on
  sig.issue_id = t.id
group by
  sig.name

union
select
  'iage;' || t.repo_group || '_' || substring(sig.name from 5) || '_All_All;n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
join
  iage_labels_sig_{{rnd}} sig
on
  sig.issue_id = t.id
where
  t.repo_group is not null
group by
  t.repo_group,
  sig.name

union
select
  'iage;All_All_' || substring(kind.name from 6) || '_All;n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
join
  iage_labels_kind_{{rnd}} kind
on
  kind.issue_id = t.id
group by
  kind.name

union
select
  'iage;' || t.repo_group || '_All_' || substring(kind.name from 6) || '_All;n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
join
  iage_labels_kind_{{rnd}} kind
on
  kind.issue_id = t.id
where
  t.repo_group is not null
group by
  t.repo_group,
  kind.name

union
select
  'iage;All_' || substring(sig.name from 5) || '_' || substring(kind.name from 6) || '_All;n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
join
  iage_labels_sig_{{rnd}} sig
on
  sig.issue_id = t.id
join
  iage_labels_kind_{{rnd}} kind
on
  kind.issue_id = t.id
group by
  sig.name,
  kind.name

union
select
  'iage;' || t.repo_group || '_' || substring(sig.name from 5) || '_' || substring(kind.name from 6) || '_All;n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
join
  iage_labels_sig_{{rnd}} sig
on
  sig.issue_id = t.id
join
  iage_labels_kind_{{rnd}} kind
on
  kind.issue_id = t.id
where
  t.repo_group is not null
group by
  t.repo_group,
  sig.name,
  kind.name

union
select
  'iage;All_All_All_' || substring(prio.name from 10) || ';n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
join
  iage_labels_prio_{{rnd}} prio
on
  prio.issue_id = t.id
group by
  prio.name

union
select
  'iage;' || t.repo_group || '_All_All_' || substring(prio.name from 10) || ';n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
join
  iage_labels_prio_{{rnd}} prio
on
  prio.issue_id = t.id
where
  t.repo_group is not null
group by
  t.repo_group,
  prio.name

union
select
  'iage;All_' || substring(sig.name from 5) || '_All_' || substring(prio.name from 10) || ';n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
join
  iage_labels_sig_{{rnd}} sig
on
  sig.issue_id = t.id
join
  iage_labels_prio_{{rnd}} prio
on
  prio.issue_id = t.id
group by
  sig.name,
  prio.name

union
select
  'iage;' || t.repo_group || '_' || substring(sig.name from 5) || '_All_' || substring(prio.name from 10) || ';n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
join
  iage_labels_sig_{{rnd}} sig
on
  sig.issue_id = t.id
join
  iage_labels_prio_{{rnd}} prio
on
  prio.issue_id = t.id
where
  t.repo_group is not null
group by
  t.repo_group,
  sig.name,
  prio.name

union
select
  'iage;All_All_' || substring(kind.name from 6) || '_' || substring(prio.name from 10) || ';n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
join
  iage_labels_kind_{{rnd}} kind
on
  kind.issue_id = t.id
join
  iage_labels_prio_{{rnd}} prio
on
  prio.issue_id = t.id
group by
  kind.name,
  prio.name

union
select
  'iage;' || t.repo_group || '_All_' || substring(kind.name from 6) || '_' || substring(prio.name from 10) || ';n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
join
  iage_labels_kind_{{rnd}} kind
on
  kind.issue_id = t.id
join
  iage_labels_prio_{{rnd}} prio
on
  prio.issue_id = t.id
where
  t.repo_group is not null
group by
  t.repo_group,
  kind.name,
  prio.name

union
select
  'iage;All_' || substring(sig.name from 5) || '_' || substring(kind.name from 6) || '_' || substring(prio.name from 10) || ';n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
join
  iage_labels_sig_{{rnd}} sig
on
  sig.issue_id = t.id
join
  iage_labels_kind_{{rnd}} kind
on
  kind.issue_id = t.id
join
  iage_labels_prio_{{rnd}} prio
on
  prio.issue_id = t.id
group by
  sig.name,
  kind.name,
  prio.name

union
select
  'iage;' || t.repo_group || '_' || substring(sig.name from 5) || '_' || substring(kind.name from 6) || '_' || substring(prio.name from 10) || ';n,m' as name,
  round(count(distinct t.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by t.age asc) as age_median
from
  iage_tdiffs_{{rnd}} t
join
  iage_labels_sig_{{rnd}} sig
on
  sig.issue_id = t.id
join
  iage_labels_kind_{{rnd}} kind
on
  kind.issue_id = t.id
join
  iage_labels_prio_{{rnd}} prio
on
  prio.issue_id = t.id
where
  t.repo_group is not null
group by
  t.repo_group,
  sig.name,
  kind.name,
  prio.name

order by
  age_median asc,
  name asc
;

