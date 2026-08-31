-- ev_logins/ok_logins evaluate the ~100 like patterns of exclude_bots once
-- per distinct login, the materialized CTEs stop the planner from pushing the
-- patterns down to per-row level on the gha_events scan
with ev_logins as materialized (
  select distinct
    lower(ev.dup_actor_login) as login
  from
    gha_events ev
  where
    ev.created_at >= '{{from}}'
    and ev.created_at < '{{to}}'
), ok_logins as materialized (
  select
    login
  from
    ev_logins
  where
    (login {{exclude_bots}})
)
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
    and lower(ev.dup_actor_login) in (select login from ok_logins)
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
order by
  activity desc,
  repo_group asc
;
