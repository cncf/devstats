create temp table issues_{{rnd}} as
select distinct
  id,
  user_id,
  created_at
from
  gha_issues
where
  is_pull_request = true
  and created_at >= '{{from}}'
  and created_at < '{{to}}'
  and (lower(dup_user_login) {{exclude_bots}})
;
create index on issues_{{rnd}}(id);
analyze issues_{{rnd}};

create temp table prs_{{rnd}} as
select distinct
  id,
  user_id,
  created_at
from
  gha_pull_requests
where
  created_at >= '{{from}}'
  and created_at < '{{to}}'
  and (lower(dup_user_login) {{exclude_bots}})
;
create index on prs_{{rnd}}(id);
analyze prs_{{rnd}};

create temp table issues_next_{{rnd}} as
select
  c.id,
  c.created_at,
  x.repo_id,
  x.repo_name,
  x.updated_at,
  x.event_id,
  r.repo_group
from
  issues_{{rnd}} c
join lateral (
  select
    n.dup_repo_id as repo_id,
    n.dup_repo_name as repo_name,
    n.updated_at,
    n.event_id
  from
    gha_issues n
  where
    n.id = c.id
    and n.is_pull_request = true
    and n.dup_actor_id <> c.user_id
    and n.created_at >= '{{from}}'
    and n.created_at < '{{to}}'
    and n.updated_at > c.created_at + interval '30 seconds'
    and n.dup_type like '%Event'
    and (lower(n.dup_actor_login) {{exclude_bots}})
  order by
    n.updated_at asc
  limit 1
) x on true
join
  gha_repos r
on
  r.id = x.repo_id
  and r.name = x.repo_name
where
  r.repo_group is not null
;
create index on issues_next_{{rnd}}(id);
create index on issues_next_{{rnd}}(event_id);
create index on issues_next_{{rnd}}(repo_group);
analyze issues_next_{{rnd}};

create temp table prs_next_{{rnd}} as
select
  c.id,
  c.created_at,
  x.repo_id,
  x.repo_name,
  x.updated_at,
  r.repo_group
from
  prs_{{rnd}} c
join lateral (
  select
    n.dup_repo_id as repo_id,
    n.dup_repo_name as repo_name,
    n.updated_at
  from
    gha_pull_requests n
  where
    n.id = c.id
    and n.dup_actor_id <> c.user_id
    and n.created_at >= '{{from}}'
    and n.created_at < '{{to}}'
    and n.updated_at > c.created_at + interval '30 seconds'
    and n.dup_type like '%Event'
    and (lower(n.dup_actor_login) {{exclude_bots}})
  order by
    n.updated_at asc
  limit 1
) x on true
join
  gha_repos r
on
  r.id = x.repo_id
  and r.name = x.repo_name
where
  r.repo_group is not null
;
create index on prs_next_{{rnd}}(id);
create index on prs_next_{{rnd}}(repo_group);
analyze prs_next_{{rnd}};

create temp table issues_next_labels_{{rnd}} as
select
  i.id,
  i.created_at,
  i.updated_at,
  i.repo_group,
  substring(l.label_name from 6) as label
from
  issues_next_{{rnd}} i
join
  gha_issues_events_labels l
on
  l.issue_id = i.id
  and l.event_id = i.event_id
where
  l.label_name in (
    'kind/api-change', 'kind/bug', 'kind/feature', 'kind/design',
    'kind/cleanup', 'kind/documentation', 'kind/flake', 'kind/kep'
  )
;
create index on issues_next_labels_{{rnd}}(label);
create index on issues_next_labels_{{rnd}}(repo_group);
analyze issues_next_labels_{{rnd}};

create temp table tdiffs_{{rnd}} as
select
  id,
  extract(epoch from updated_at - created_at) / 3600.0 as diff,
  repo_group,
  'All'::text as label
from
  issues_next_{{rnd}}
union
select
  id,
  extract(epoch from updated_at - created_at) / 3600.0 as diff,
  repo_group,
  'All'::text as label
from
  prs_next_{{rnd}}
union
select
  id,
  extract(epoch from updated_at - created_at) / 3600.0 as diff,
  repo_group,
  label
from
  issues_next_labels_{{rnd}}
;
create index on tdiffs_{{rnd}}(label);
create index on tdiffs_{{rnd}}(repo_group, label);
analyze tdiffs_{{rnd}};

select
  case
    when repo_group is null then 'non_auth;All,' || label || ';p15,med,p85'
    else 'non_auth;' || repo_group || ',' || label || ';p15,med,p85'
  end as name,
  (pcts)[1] as non_author_15_percentile,
  (pcts)[2] as non_author_median,
  (pcts)[3] as non_author_85_percentile
from (
  select
    repo_group,
    label,
    percentile_disc(array[0.15, 0.5, 0.85]) within group (order by diff asc) as pcts
  from
    tdiffs_{{rnd}}
  group by
    grouping sets ((label), (repo_group, label))
) s
order by
  (pcts)[2] desc,
  name asc
;

