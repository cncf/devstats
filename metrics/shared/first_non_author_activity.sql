create temp table issues_next_{{rnd}} as
select
  n.id,
  n.created_at,
  n.dup_repo_id as repo_id,
  n.dup_repo_name as repo_name,
  min(n.updated_at) as updated_at
from
  gha_issues n
where
  n.is_pull_request = true
  and n.created_at >= '{{from}}'
  and n.created_at < '{{to}}'
  and (lower(n.dup_user_login) {{exclude_bots}})
  and n.dup_actor_id <> n.user_id
  and n.updated_at > n.created_at + interval '30 seconds'
  and n.dup_type like '%Event'
  and (lower(n.dup_actor_login) {{exclude_bots}})
group by
  n.id,
  n.created_at,
  n.dup_repo_id,
  n.dup_repo_name
;
analyze issues_next_{{rnd}};

create temp table prs_next_{{rnd}} as
select
  n.id,
  n.created_at,
  n.dup_repo_id as repo_id,
  n.dup_repo_name as repo_name,
  min(n.updated_at) as updated_at
from
  gha_pull_requests n
where
  n.created_at >= '{{from}}'
  and n.created_at < '{{to}}'
  and (lower(n.dup_user_login) {{exclude_bots}})
  and n.dup_actor_id <> n.user_id
  and n.updated_at > n.created_at + interval '30 seconds'
  and n.dup_type like '%Event'
  and (lower(n.dup_actor_login) {{exclude_bots}})
group by
  n.id,
  n.created_at,
  n.dup_repo_id,
  n.dup_repo_name
;
analyze prs_next_{{rnd}};

create temp table tdiffs_{{rnd}} as
select
  i.id,
  extract(epoch from i.updated_at - i.created_at) / 3600.0 as diff,
  r.repo_group as repo_group
from
  issues_next_{{rnd}} i
join
  gha_repo_groups r
on
  r.id = i.repo_id
  and r.name = i.repo_name
  and r.repo_group is not null
union
select
  p.id,
  extract(epoch from p.updated_at - p.created_at) / 3600.0 as diff,
  r.repo_group as repo_group
from
  prs_next_{{rnd}} p
join
  gha_repo_groups r
on
  r.id = p.repo_id
  and r.name = p.repo_name
  and r.repo_group is not null
;
analyze tdiffs_{{rnd}};

select
  case
    when repo_group is null then 'non_auth;All;p15,med,p85'
    else 'non_auth;' || repo_group || ';p15,med,p85'
  end as name,
  (pcts)[1] as non_author_15_percentile,
  (pcts)[2] as non_author_median,
  (pcts)[3] as non_author_85_percentile
from (
  select
    repo_group,
    percentile_disc(array[0.15, 0.5, 0.85]) within group (order by diff asc) as pcts
  from
    tdiffs_{{rnd}}
  group by
    grouping sets ((), (repo_group))
) s
order by
  (pcts)[2] desc,
  name asc
;

