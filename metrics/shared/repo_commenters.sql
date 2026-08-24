create temp table rc_{{rnd}} as
select
  t.actor_login,
  t.repo_id,
  t.repo_name
from
  gha_texts t
where
  t.created_at >= '{{from}}'
  and t.created_at < '{{to}}'
  and (lower(t.actor_login) {{exclude_bots}})
;
analyze rc_{{rnd}};

select
  'rcommenters,All' as repo_group,
  round(count(distinct t.actor_login) / {{n}}, 2) as result
from
  rc_{{rnd}} t
union select sub.repo_group,
  round(count(distinct sub.actor_login) / {{n}}, 2) as result
from (
  select 'rcommenters,' || r.repo_group as repo_group,
    t.actor_login
  from
    gha_repo_groups r,
    rc_{{rnd}} t
  where
    r.id = t.repo_id
    and r.name = t.repo_name
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
order by
  result desc,
  repo_group asc
;
drop table rc_{{rnd}};
