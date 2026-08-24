create temp table dce_commits_{{rnd}} as
select
  c.sha,
  c.author_id,
  c.dup_created_at,
  c.dup_repo_id as repo_id,
  c.dup_repo_name as repo_name,
  ecf.repo_group as ecf_repo_group
from
  gha_events_commits_files ecf,
  gha_commits c
where
  c.sha = ecf.sha
  and lower(ecf.path) like '%.rst'
  and c.dup_created_at >= '{{from}}'
  and c.dup_created_at < '{{to}}'
  and (lower(c.dup_author_login) {{exclude_bots}})
;
analyze dce_commits_{{rnd}};

create temp table dce_company_{{rnd}} as
select
  affs.company_name,
  c.author_id,
  c.repo_id,
  c.repo_name,
  c.ecf_repo_group
from
  dce_commits_{{rnd}} c
left join
  gha_actors_affiliations affs
on
  c.author_id = affs.actor_id
  and affs.dt_from <= c.dup_created_at
  and affs.dt_to > c.dup_created_at
  and affs.company_name != ''
;
analyze dce_company_{{rnd}};

select
  'docstats;All;comps,devs' as name,
  count(distinct company_name) as n_companies,
  count(distinct author_id) as n_authors
from
  dce_company_{{rnd}}
union select sub.name,
  count(distinct sub.company_name) as n_companies,
  count(distinct sub.author_id) as n_authors
from (
  select 'docstats;' || coalesce(c.ecf_repo_group, r.repo_group) || ';comps,devs' as name,
    c.company_name,
    c.author_id
  from
    gha_repos r,
    dce_company_{{rnd}} c
  where
    c.repo_id = r.id
    and c.repo_name = r.name
  ) sub
where
  sub.name is not null
group by
  sub.name
order by
  n_companies desc,
  n_authors desc,
  name asc
;
