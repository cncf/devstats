create temp table hck_{{rnd}} as
select
  id,
  event_id,
  dup_actor_login,
  dup_repo_id,
  dup_repo_name
from
  gha_comments
where
  {{period:created_at}}
  and (lower(dup_actor_login) {{exclude_bots}})
;
analyze hck_{{rnd}};

select
  sub.repo_group,
  sub.actor,
  count(distinct sub.id) as comments
from (
  select 'htop_commenters,' || coalesce(ecf.repo_group, r.repo_group) as repo_group,
    t.dup_actor_login as actor,
    t.id
  from
    gha_repos r,
    hck_{{rnd}} t
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = t.event_id
  where
    t.dup_repo_id = r.id
    and t.dup_repo_name = r.name
  ) sub
where
  sub.repo_group is not null
group by
  sub.actor,
  sub.repo_group
having
  count(distinct sub.id) >= 1
union all select 'htop_commenters,All' as repo_group,
  dup_actor_login as actor,
  count(distinct id) as comments
from
  hck_{{rnd}}
group by
  dup_actor_login
having
  count(distinct id) >= 1
order by
  comments desc,
  repo_group asc,
  actor asc
;
drop table hck_{{rnd}};
