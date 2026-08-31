create temp table hpa_{{rnd}} as
select
  pr.id,
  pr.dup_user_login as author,
  pr.dup_repo_id as repo_id,
  pr.dup_repo_name as repo_name
from
  gha_pull_requests pr
where
  {{period:pr.created_at}}
  and (lower(pr.dup_user_login) {{exclude_bots}})
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
