create temp table hprm_prs_{{rnd}} as
select
  pr.id,
  pr.dup_repo_id as repo_id,
  pr.dup_repo_name as repo_name,
  pr.dupn_merged_by_login as merger_login
from
  gha_pull_requests pr
where
  {{period:pr.merged_at}}
  and pr.merged_at is not null
  and pr.dupn_merged_by_login is not null
;
analyze hprm_prs_{{rnd}};

create temp table hprm_bots_{{rnd}} as
select distinct
  a.login
from
  gha_actors a
where
  a.login in (select distinct merger_login from hprm_prs_{{rnd}})
  and not lower(a.login) {{exclude_bots}}
;
analyze hprm_bots_{{rnd}};

select
  sub.repo_group,
  sub.merger,
  count(distinct sub.id) as prs
from (
  select 'hpr_mergers,' || r.repo_group as repo_group,
    coalesce('*bot: ' || b.login || ' *', pr.merger_login) as merger,
    pr.id
  from
    gha_repo_groups r,
    hprm_prs_{{rnd}} pr
  left join
    hprm_bots_{{rnd}} b
  on
    pr.merger_login = b.login
  where
    pr.repo_id = r.id
    and pr.repo_name = r.name
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group,
  sub.merger
having
  count(distinct sub.id) >= 1
union select 'hpr_mergers,All' as repo_group,
  coalesce('*bot: ' || b.login || ' *', pr.merger_login) as merger,
  count(distinct pr.id) as prs
from
  hprm_prs_{{rnd}} pr
left join
  hprm_bots_{{rnd}} b
on
  pr.merger_login = b.login
group by
  pr.merger_login,
  b.login
having
  count(distinct pr.id) >= 1
order by
  prs desc,
  repo_group asc,
  merger asc
;
