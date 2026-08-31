create temp table hpa_{{rnd}} as
select
  pr.id,
  pr.dup_user_login as author,
  lower(pr.dup_user_login) as author_lower,
  pr.dup_repo_id as repo_id,
  pr.dup_repo_name as repo_name
from
  gha_pull_requests pr
where
  {{period:pr.created_at}}
;
-- filter bots once per distinct login instead of once per scanned row,
-- the temp table barrier keeps the ~100 like patterns off the base scan
create temp table hpa_logins_{{rnd}} as
select distinct author_lower as login from hpa_{{rnd}}
;
delete from hpa_{{rnd}}
where
  author_lower is null
  or author_lower in (
    select login from hpa_logins_{{rnd}} where not (login {{exclude_bots}})
  )
;
analyze hpa_{{rnd}};

select
  sub.repo_group,
  sub.author,
  count(distinct sub.id) as prs
from (
  select 'hpr_auth,' || r.repo_group as repo_group,
    pr.author,
    pr.id
  from
    gha_repo_groups r,
    hpa_{{rnd}} pr
  where
    pr.repo_id = r.id
    and pr.repo_name = r.name
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group,
  sub.author
having
  count(distinct sub.id) >= 1
union all select 'hpr_auth,All' as repo_group,
  author,
  count(distinct id) as prs
from
  hpa_{{rnd}}
group by
  author
having
  count(distinct id) >= 1
order by
  prs desc,
  repo_group asc,
  author asc
;
drop table hpa_{{rnd}};
drop table hpa_logins_{{rnd}};
