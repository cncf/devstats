with issues as (
  select distinct id,
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
  select distinct on (c.id)
    c.id,
    c.created_at,
    n.dup_repo_id as repo_id,
    n.dup_repo_name as repo_name,
    n.updated_at,
    n.event_id
  from
    issues c,
    gha_issues n
  where
    n.id = c.id
    and n.is_pull_request = true
    and n.dup_actor_id != c.user_id
    and n.created_at >= '{{from}}'
    and n.created_at < '{{to}}'
    and n.updated_at > c.created_at + '30 seconds'::interval
    and n.dup_type like '%Event'
    and (lower(n.dup_actor_login) {{exclude_bots}})
  order by
    c.id,
    n.updated_at
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
    i.id = l.issue_id
    and i.event_id = l.event_id
  where
    label_name in ('kind/api-change', 'kind/bug', 'kind/feature', 'kind/design', 'kind/cleanup', 'kind/documentation', 'kind/flake', 'kind/kep')
), prs as (
  select distinct id,
    user_id,
    created_at
  from
    gha_pull_requests
  where
    created_at >= '{{from}}'
    and created_at < '{{to}}'
    and (lower(dup_user_login) {{exclude_bots}})
), prs_next as (
  select distinct on (c.id)
    c.id,
    c.created_at,
    n.dup_repo_id as repo_id,
    n.dup_repo_name as repo_name,
    n.updated_at
  from
    prs c,
    gha_pull_requests n
  where
    n.id = c.id
    and n.dup_actor_id != c.user_id
    and n.created_at >= '{{from}}'
    and n.created_at < '{{to}}'
    and n.updated_at > c.created_at + '30 seconds'::interval
    and n.dup_type like '%Event'
    and (lower(n.dup_actor_login) {{exclude_bots}})
  order by
    c.id,
    n.updated_at
), tdiffs as (
  select
    id,
    extract(epoch from updated_at - created_at) / 3600 as diff,
    repo_name as repo,
    'All' as label
  from
    issues_next
  union select
    id,
    extract(epoch from updated_at - created_at) / 3600 as diff,
    repo_name as repo,
    'All' as label
  from
    prs_next p
  union select
    id,
    extract(epoch from updated_at - created_at) / 3600 as diff,
    repo_name as repo,
    label_sub_name as label
  from
    issues_next_labels
)
select
  'non_auth;All,' || label || ';p15,med,p85' as name,
  percentile_disc(0.15) within group (order by diff asc) as non_author_15_percentile,
  percentile_disc(0.5) within group (order by diff asc) as non_author_median,
  percentile_disc(0.85) within group (order by diff asc) as non_author_85_percentile
from
  tdiffs
group by
  label
union select 'non_auth;' || repo || ',' || label || ';p15,med,p85' as name,
  percentile_disc(0.15) within group (order by diff asc) as non_author_15_percentile,
  percentile_disc(0.5) within group (order by diff asc) as non_author_median,
  percentile_disc(0.85) within group (order by diff asc) as non_author_85_percentile
from
  tdiffs
group by
  label,
  repo
order by
  non_author_median desc,
  name asc
;
