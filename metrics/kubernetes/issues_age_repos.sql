create temp table trepos_{{rnd}} as
select distinct
  repo_name
from
  trepos
;
create unique index on trepos_{{rnd}}(repo_name);
analyze trepos_{{rnd}};

create temp table issue_ids_{{rnd}} as
select distinct
  i.id
from
  gha_issues i
join
  trepos_{{rnd}} tr
on
  tr.repo_name = i.dup_repo_name
where
  i.is_pull_request = false
  and i.closed_at is not null
  and i.created_at >= '{{from}}'
  and i.created_at < '{{to}}'
;
create unique index on issue_ids_{{rnd}}(id);
analyze issue_ids_{{rnd}};

create temp table issues_latest_{{rnd}} as
select distinct on (i.id)
  i.id,
  i.is_pull_request,
  i.dup_repo_name as repo,
  i.created_at,
  i.closed_at
from
  gha_issues i
join
  issue_ids_{{rnd}} ids
on
  ids.id = i.id
order by
  i.id,
  i.updated_at desc
;
create unique index on issues_latest_{{rnd}}(id);
create index on issues_latest_{{rnd}}(repo);
analyze issues_latest_{{rnd}};

create temp table issues_{{rnd}} as
select
  l.id,
  l.repo,
  l.created_at,
  l.closed_at
from
  issues_latest_{{rnd}} l
join
  trepos_{{rnd}} tr
on
  tr.repo_name = l.repo
where
  l.is_pull_request = false
  and l.closed_at is not null
  and l.created_at >= '{{from}}'
  and l.created_at < '{{to}}'
;
create unique index on issues_{{rnd}}(id);
create index on issues_{{rnd}}(repo);
analyze issues_{{rnd}};

create temp table tdiffs_{{rnd}} as
select
  id,
  repo,
  extract(epoch from closed_at - created_at) / 3600 as age
from
  issues_{{rnd}}
;
create unique index on tdiffs_{{rnd}}(id);
create index on tdiffs_{{rnd}}(repo);
analyze tdiffs_{{rnd}};

create temp table tsig_mentions_labels_{{rnd}} as
select distinct
  sig_mentions_labels_name
from
  tsig_mentions_labels
;
create unique index on tsig_mentions_labels_{{rnd}}(sig_mentions_labels_name);
analyze tsig_mentions_labels_{{rnd}};

create temp table labels_{{rnd}} as
select distinct
  l.issue_id,
  case l.dup_label_name
    when 'sig/aws' then 'sig/cloud-provider'
    when 'sig/azure' then 'sig/cloud-provider'
    when 'sig/batchd' then 'sig/cloud-provider'
    when 'sig/cloud-provider-aws' then 'sig/cloud-provider'
    when 'sig/gcp' then 'sig/cloud-provider'
    when 'sig/ibmcloud' then 'sig/cloud-provider'
    when 'sig/openstack' then 'sig/cloud-provider'
    when 'sig/vmware' then 'sig/cloud-provider'
    else l.dup_label_name
  end as name
from
  gha_issues_labels l
join
  issues_{{rnd}} i
on
  i.id = l.issue_id
join
  tsig_mentions_labels_{{rnd}} sml
on
  sml.sig_mentions_labels_name = substring(l.dup_label_name from 5)
where
  l.dup_created_at >= '{{from}}'
  and l.dup_created_at < '{{to}}'
  and (
    l.dup_label_name like 'sig/%'
    or l.dup_label_name like 'kind/%'
    or l.dup_label_name like 'priority/%'
  )
  and substring(l.dup_label_name from 5) not in (
    'apimachinery', 'api-machiner', 'cloude-provider', 'nework',
    'scalability-proprosals', 'storge', 'ui-preview-reviewes',
    'cluster-fifecycle', 'rktnetes'
  )
  and l.dup_label_name not like '%use-only-as-a-last-resort'
;
create index on labels_{{rnd}}(issue_id);
create index on labels_{{rnd}}(name);
create index on labels_{{rnd}}(issue_id, name);
analyze labels_{{rnd}};

create temp table sig_map_{{rnd}} as
select distinct
  issue_id,
  substring(name from 5) as sig
from
  labels_{{rnd}}
where
  name like 'sig/%'
;
create index on sig_map_{{rnd}}(issue_id);
create index on sig_map_{{rnd}}(sig);
create index on sig_map_{{rnd}}(issue_id, sig);
analyze sig_map_{{rnd}};

create temp table kind_map_{{rnd}} as
select distinct
  issue_id,
  substring(name from 6) as kind
from
  labels_{{rnd}}
where
  name like 'kind/%'
;
create index on kind_map_{{rnd}}(issue_id);
create index on kind_map_{{rnd}}(kind);
create index on kind_map_{{rnd}}(issue_id, kind);
analyze kind_map_{{rnd}};

create temp table prio_map_{{rnd}} as
select distinct
  issue_id,
  substring(name from 10) as prio
from
  labels_{{rnd}}
where
  name like 'priority/%'
;
create index on prio_map_{{rnd}}(issue_id);
create index on prio_map_{{rnd}}(prio);
create index on prio_map_{{rnd}}(issue_id, prio);
analyze prio_map_{{rnd}};

create temp table sig_age_{{rnd}} as
select
  t.id,
  t.repo,
  s.sig,
  t.age
from
  tdiffs_{{rnd}} t
join
  sig_map_{{rnd}} s
on
  s.issue_id = t.id
;
create index on sig_age_{{rnd}}(id);
create index on sig_age_{{rnd}}(repo);
create index on sig_age_{{rnd}}(sig);
create index on sig_age_{{rnd}}(repo, sig);
analyze sig_age_{{rnd}};

create temp table kind_age_{{rnd}} as
select
  t.id,
  t.repo,
  k.kind,
  t.age
from
  tdiffs_{{rnd}} t
join
  kind_map_{{rnd}} k
on
  k.issue_id = t.id
;
create index on kind_age_{{rnd}}(id);
create index on kind_age_{{rnd}}(repo);
create index on kind_age_{{rnd}}(kind);
create index on kind_age_{{rnd}}(repo, kind);
analyze kind_age_{{rnd}};

create temp table prio_age_{{rnd}} as
select
  t.id,
  t.repo,
  p.prio,
  t.age
from
  tdiffs_{{rnd}} t
join
  prio_map_{{rnd}} p
on
  p.issue_id = t.id
;
create index on prio_age_{{rnd}}(id);
create index on prio_age_{{rnd}}(repo);
create index on prio_age_{{rnd}}(prio);
create index on prio_age_{{rnd}}(repo, prio);
analyze prio_age_{{rnd}};

select
  name,
  num,
  age_median
from (
  select
    case when grouping(repo) = 1 then 'iage;All_All_All_All;n,m' else 'iage;' || repo || '_All_All_All;n,m' end as name,
    round(count(distinct id) / {{n}}, 2) as num,
    percentile_disc(0.5) within group (order by age asc) as age_median
  from
    tdiffs_{{rnd}}
  group by
    grouping sets ((), (repo))

  union all
  select
    case when grouping(repo) = 1 then 'iage;All_' || sig || '_All_All;n,m' else 'iage;' || repo || '_' || sig || '_All_All;n,m' end as name,
    round(count(distinct id) / {{n}}, 2) as num,
    percentile_disc(0.5) within group (order by age asc) as age_median
  from
    sig_age_{{rnd}}
  group by
    grouping sets ((sig), (repo, sig))

  union all
  select
    case when grouping(repo) = 1 then 'iage;All_All_' || kind || '_All;n,m' else 'iage;' || repo || '_All_' || kind || '_All;n,m' end as name,
    round(count(distinct id) / {{n}}, 2) as num,
    percentile_disc(0.5) within group (order by age asc) as age_median
  from
    kind_age_{{rnd}}
  group by
    grouping sets ((kind), (repo, kind))

  union all
  select
    case when grouping(repo) = 1 then 'iage;All_' || sig || '_' || kind || '_All;n,m' else 'iage;' || repo || '_' || sig || '_' || kind || '_All;n,m' end as name,
    round(count(distinct id) / {{n}}, 2) as num,
    percentile_disc(0.5) within group (order by age asc) as age_median
  from (
    select
      s.id,
      s.repo,
      s.sig,
      k.kind,
      s.age
    from
      sig_age_{{rnd}} s
    join
      kind_map_{{rnd}} k
    on
      k.issue_id = s.id
  ) x
  group by
    grouping sets ((sig, kind), (repo, sig, kind))

  union all
  select
    case when grouping(repo) = 1 then 'iage;All_All_All_' || prio || ';n,m' else 'iage;' || repo || '_All_All_' || prio || ';n,m' end as name,
    round(count(distinct id) / {{n}}, 2) as num,
    percentile_disc(0.5) within group (order by age asc) as age_median
  from
    prio_age_{{rnd}}
  group by
    grouping sets ((prio), (repo, prio))

  union all
  select
    case when grouping(repo) = 1 then 'iage;All_' || sig || '_All_' || prio || ';n,m' else 'iage;' || repo || '_' || sig || '_All_' || prio || ';n,m' end as name,
    round(count(distinct id) / {{n}}, 2) as num,
    percentile_disc(0.5) within group (order by age asc) as age_median
  from (
    select
      s.id,
      s.repo,
      s.sig,
      p.prio,
      s.age
    from
      sig_age_{{rnd}} s
    join
      prio_map_{{rnd}} p
    on
      p.issue_id = s.id
  ) x
  group by
    grouping sets ((sig, prio), (repo, sig, prio))

  union all
  select
    case when grouping(repo) = 1 then 'iage;All_All_' || kind || '_' || prio || ';n,m' else 'iage;' || repo || '_All_' || kind || '_' || prio || ';n,m' end as name,
    round(count(distinct id) / {{n}}, 2) as num,
    percentile_disc(0.5) within group (order by age asc) as age_median
  from (
    select
      k.id,
      k.repo,
      k.kind,
      p.prio,
      k.age
    from
      kind_age_{{rnd}} k
    join
      prio_map_{{rnd}} p
    on
      p.issue_id = k.id
  ) x
  group by
    grouping sets ((kind, prio), (repo, kind, prio))

  union all
  select
    case when grouping(repo) = 1 then 'iage;All_' || sig || '_' || kind || '_' || prio || ';n,m' else 'iage;' || repo || '_' || sig || '_' || kind || '_' || prio || ';n,m' end as name,
    round(count(distinct id) / {{n}}, 2) as num,
    percentile_disc(0.5) within group (order by age asc) as age_median
  from (
    select
      s.id,
      s.repo,
      s.sig,
      k.kind,
      p.prio,
      s.age
    from
      sig_age_{{rnd}} s
    join
      kind_map_{{rnd}} k
    on
      k.issue_id = s.id
    join
      prio_map_{{rnd}} p
    on
      p.issue_id = s.id
  ) x
  group by
    grouping sets ((sig, kind, prio), (repo, sig, kind, prio))
) final
order by
  age_median asc,
  name asc
;

