select
  'new_prs,All' as repo_group,
  round(count(distinct id) / {{n}}, 2) as new
from
  gha_pull_requests
where
  created_at >= '{{from}}'
  and created_at < '{{to}}'
  and (lower(dup_user_login) {{exclude_bots}})
union select 'new_prs,' || r.repo_group as repo_group,
  round(count(distinct pr.id) / {{n}}, 2) as new
from
  gha_pull_requests pr,
  gha_repo_groups r
where
  pr.dup_repo_id = r.id
  and pr.dup_repo_name = r.name
  and r.repo_group is not null
  and pr.created_at >= '{{from}}'
  and pr.created_at < '{{to}}'
  and (lower(pr.dup_user_login) {{exclude_bots}})
group by
  r.repo_group
union select 'new_prs_bots,All' as repo_group,
  round(count(distinct id) / {{n}}, 2) as new
from
  gha_pull_requests
where
  created_at >= '{{from}}'
  and created_at < '{{to}}'
union select 'new_prs_bots,' || r.repo_group as repo_group,
  round(count(distinct pr.id) / {{n}}, 2) as new
from
  gha_pull_requests pr,
  gha_repo_groups r
where
  pr.dup_repo_id = r.id
  and pr.dup_repo_name = r.name
  and r.repo_group is not null
  and pr.created_at >= '{{from}}'
  and pr.created_at < '{{to}}'
group by
  r.repo_group
order by
  new desc,
  repo_group asc
;
