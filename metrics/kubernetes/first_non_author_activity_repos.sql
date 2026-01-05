with issues as (
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
), issues_next as (
  select
    c.id,
    c.created_at,
    n.dup_repo_id as repo_id,
    n.dup_repo_name as repo_name,
    n.updated_at,
    n.event_id
  from
    issues c
  join lateral (
    select
      n.dup_repo_id,
      n.dup_repo_name,
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
      n.updated_at asc,
      n.event_id asc
    limit 1
  ) n on true
), issues_next_labels as (
  select
    i.id,
    i.created_at,
    i.repo_id,
    i.repo_name,
    i.updated_at,
    substring(l.label_name from 6) as label_sub_name
  from
    issues_next i
  inner join
    gha_issues_events_labels l
  on
    l.issue_id = i.id
    and l.event_id = i.event_id
  where
    l.label_name in (
      'kind/api-change', 'kind/bug', 'kind/feature', 'kind/design',
      'kind/cleanup', 'kind/documentation', 'kind/flake', 'kind/kep'
    )
), prs as (
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
), prs_next as (
  select
    c.id,
    c.created_at,
    n.dup_repo_id as repo_id,
    n.dup_repo_name as repo_name,
    n.updated_at
  from
    prs c
  join lateral (
    select
      n.dup_repo_id,
      n.dup_repo_name,
      n.updated_at,
      n.event_id
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
      n.updated_at asc,
      n.event_id asc
    limit 1
  ) n on true
), tdiffs as (
  select
    id,
    extract(epoch from updated_at - created_at) / 3600.0 as diff,
    repo_name as repo,
    'All'::text as label
  from
    issues_next
  union
  select
    id,
    extract(epoch from updated_at - created_at) / 3600.0 as diff,
    repo_name as repo,
    'All'::text as label
  from
    prs_next
  union
  select
    id,
    extract(epoch from updated_at - created_at) / 3600.0 as diff,
    repo_name as repo,
    label_sub_name as label
  from
    issues_next_labels
), agg as (
  select
    repo,
    label,
    percentile_disc(array[0.15, 0.5, 0.85]) within group (order by diff asc) as p
  from
    tdiffs
  group by
    grouping sets ((label), (repo, label))
)
select
  case
    when repo is null then 'non_auth;All,' || label || ';p15,med,p85'
    else 'non_auth;' || repo || ',' || label || ';p15,med,p85'
  end as name,
  (p)[1] as non_author_15_percentile,
  (p)[2] as non_author_median,
  (p)[3] as non_author_85_percentile
from
  agg
order by
  non_author_median desc,
  name asc
;

