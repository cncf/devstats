with pr_affiliations as materialized (
  select
    pr.id,
    pr.dup_repo_id,
    pr.dup_repo_name,
    a.company_name as company
  from
    gha_pull_requests pr
  join
    gha_actors_affiliations a
  on
    a.actor_id = pr.user_id
    and a.dt_from <= pr.created_at
    and a.dt_to > pr.created_at
  where
    {{period:pr.created_at}}
    and (lower(pr.dup_user_login) {{exclude_bots}})
    and a.company_name != ''
)
select
  sub.repo_group,
  sub.company,
  count(distinct sub.id) as prs
from (
  select
    'hpr_comps,' || r.repo_group as repo_group,
    p.company,
    p.id
  from
    pr_affiliations p
  join
    gha_repo_groups r
  on
    r.id = p.dup_repo_id
    and r.name = p.dup_repo_name
) sub
where
  sub.repo_group is not null
group by
  sub.repo_group,
  sub.company
having
  count(distinct sub.id) >= 1

union

select
  'hpr_comps,All' as repo_group,
  company,
  count(distinct id) as prs
from
  pr_affiliations
group by
  company
having
  count(distinct id) >= 1

order by
  prs desc,
  repo_group asc,
  company asc
;
