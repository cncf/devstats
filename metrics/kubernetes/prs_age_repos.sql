create temp table trepos_{{rnd}} as
select distinct
  repo_name
from
  trepos
;
create unique index on trepos_{{rnd}}(repo_name);
analyze trepos_{{rnd}};

create temp table pr_ids_{{rnd}} as
select distinct
  id
from
  gha_pull_requests
where
  created_at >= '{{from}}'
  and created_at < '{{to}}'
;
create unique index on pr_ids_{{rnd}}(id);
analyze pr_ids_{{rnd}};

create temp table pr_latest_{{rnd}} as
select distinct on (pr.id)
  pr.id,
  pr.event_id
from
  gha_pull_requests pr
join
  pr_ids_{{rnd}} i
on
  i.id = pr.id
order by
  pr.id,
  pr.updated_at desc
;
create unique index on pr_latest_{{rnd}}(id);
create index on pr_latest_{{rnd}}(id, event_id);
analyze pr_latest_{{rnd}};

create temp table prs_{{rnd}} as
select
  pr.id,
  pr.dup_repo_id as repo_id,
  pr.dup_repo_name as repo_name,
  pr.created_at,
  pr.merged_at
from
  gha_pull_requests pr
join
  pr_latest_{{rnd}} l
on
  l.id = pr.id
  and l.event_id = pr.event_id
where
  pr.created_at >= '{{from}}'
  and pr.created_at < '{{to}}'
;
create unique index on prs_{{rnd}}(id);
create index on prs_{{rnd}}(repo_name);
create index on prs_{{rnd}}(repo_id, repo_name);
analyze prs_{{rnd}};

create temp table ipr_{{rnd}} as
select distinct
  ipr.pull_request_id,
  ipr.issue_id,
  ipr.repo_id,
  ipr.repo_name
from
  gha_issues_pull_requests ipr
join
  prs_{{rnd}} pr
on
  pr.id = ipr.pull_request_id
  and pr.repo_id = ipr.repo_id
  and pr.repo_name = ipr.repo_name
where
  ipr.created_at >= '{{from}}'
  and ipr.created_at < '{{to}}'
;
create index on ipr_{{rnd}}(pull_request_id);
create index on ipr_{{rnd}}(issue_id);
create index on ipr_{{rnd}}(pull_request_id, repo_id, repo_name);
analyze ipr_{{rnd}};

create temp table iel_{{rnd}} as
select distinct
  issue_id,
  label_name
from
  gha_issues_events_labels
where
  created_at >= '{{from}}'
  and created_at < '{{to}}'
  and label_name in (
    'kind/api-change', 'kind/bug', 'kind/feature', 'kind/design',
    'kind/cleanup', 'kind/documentation', 'kind/flake', 'kind/kep'
  )
;
create index on iel_{{rnd}}(issue_id);
create index on iel_{{rnd}}(label_name);
create index on iel_{{rnd}}(issue_id, label_name);
analyze iel_{{rnd}};

create temp table prs_labels_{{rnd}} as
select distinct
  pr.id,
  pr.repo_id,
  pr.repo_name,
  iel.label_name,
  pr.created_at,
  pr.merged_at
from
  prs_{{rnd}} pr
join
  ipr_{{rnd}} ipr
on
  pr.id = ipr.pull_request_id
  and pr.repo_id = ipr.repo_id
  and pr.repo_name = ipr.repo_name
join
  iel_{{rnd}} iel
on
  ipr.issue_id = iel.issue_id
;
create index on prs_labels_{{rnd}}(id);
create index on prs_labels_{{rnd}}(repo_name);
create index on prs_labels_{{rnd}}(label_name);
create index on prs_labels_{{rnd}}(repo_name, label_name);
analyze prs_labels_{{rnd}};

create temp table prs_age_{{rnd}} as
select
  id,
  repo_name as repo,
  extract(epoch from coalesce(merged_at - created_at, now() - created_at)) / 3600 as age
from
  prs_{{rnd}}
;
create index on prs_age_{{rnd}}(repo);
create index on prs_age_{{rnd}}(id);
create index on prs_age_{{rnd}}(repo, id);
analyze prs_age_{{rnd}};

create temp table prs_labels_age_{{rnd}} as
select
  id,
  repo_name as repo,
  substring(label_name from 6) as label,
  extract(epoch from coalesce(merged_at - created_at, now() - created_at)) / 3600 as age
from
  prs_labels_{{rnd}}
;
create index on prs_labels_age_{{rnd}}(label);
create index on prs_labels_age_{{rnd}}(repo);
create index on prs_labels_age_{{rnd}}(repo, label);
create index on prs_labels_age_{{rnd}}(id);
analyze prs_labels_age_{{rnd}};

select
  'prs_age;All,All;n,m' as name,
  round(count(distinct id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by age asc) as age_median
from
  prs_age_{{rnd}}

union
select
  'prs_age;' || a.repo || ',All;n,m' as name,
  round(count(distinct a.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by a.age asc) as age_median
from
  prs_age_{{rnd}} a
join
  trepos_{{rnd}} tr
on
  tr.repo_name = a.repo
group by
  a.repo

union
select
  'prs_age;All,' || label || ';n,m' as name,
  round(count(distinct id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by age asc) as age_median
from
  prs_labels_age_{{rnd}}
group by
  label

union
select
  'prs_age;' || a.repo || ',' || a.label || ';n,m' as name,
  round(count(distinct a.id) / {{n}}, 2) as num,
  percentile_disc(0.5) within group (order by a.age asc) as age_median
from
  prs_labels_age_{{rnd}} a
join
  trepos_{{rnd}} tr
on
  tr.repo_name = a.repo
group by
  a.repo,
  a.label

order by
  num desc,
  name asc
;

