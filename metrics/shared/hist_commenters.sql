-- temp_buffers must be set before the session touches any temp table,
-- calc_metric reuses sessions across ranges, so ignore the error then
do $$ begin
  begin
    set temp_buffers = '1GB';
  exception when others then
    null;
  end;
end $$;

-- scan gha_comments once (the 'All' and per repo group branches below reuse it)
-- and evaluate the ~100 like patterns of exclude_bots once per distinct login
create temp table hc_comments_{{rnd}} as
select
  t.id,
  t.dup_actor_login as actor,
  lower(t.dup_actor_login) as actor_lower,
  t.dup_repo_id as repo_id,
  t.dup_repo_name as repo_name
from
  gha_comments t
where
  {{period:t.created_at}}
;
create temp table hc_logins_{{rnd}} as
select distinct actor_lower as login from hc_comments_{{rnd}}
;
delete from hc_comments_{{rnd}}
where
  actor_lower is null
  or actor_lower in (
    select login from hc_logins_{{rnd}} where not (login {{exclude_bots}})
  )
;
analyze hc_comments_{{rnd}};

select
  sub.repo_group,
  sub.actor,
  count(distinct sub.id) as comments
from (
  select 'htop_commenters,' || r.repo_group as repo_group,
    t.actor,
    t.id
  from
    gha_repo_groups r,
    hc_comments_{{rnd}} t
  where
    t.repo_id = r.id
    and t.repo_name = r.name
  ) sub
where
  sub.repo_group is not null
group by
  sub.actor,
  sub.repo_group
having
  count(distinct sub.id) >= 1
union select 'htop_commenters,All' as repo_group,
  actor,
  count(distinct id) as comments
from
  hc_comments_{{rnd}}
group by
  actor
having
  count(distinct id) >= 1
order by
  comments desc,
  repo_group asc,
  actor asc
;
drop table hc_comments_{{rnd}};
drop table hc_logins_{{rnd}};
