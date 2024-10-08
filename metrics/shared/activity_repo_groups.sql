select
  sub.repo_group,
  round(count(distinct sub.id) / {{n}}, 2) as activity
from (
  select 'act,' || r.repo_group as repo_group,
    ev.id
  from
    gha_repo_groups r,
    gha_events ev
  where
    r.name = ev.dup_repo_name
    and r.id = ev.repo_id
    and r.name in (select repo_name from trepos)
    and ev.created_at >= '{{from}}'
    and ev.created_at < '{{to}}'
    and (lower(ev.dup_actor_login) {{exclude_bots}})
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
order by
  activity desc,
  repo_group asc
;
