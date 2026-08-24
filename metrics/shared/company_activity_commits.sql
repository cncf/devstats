create temp table cac_commits_{{rnd}} as
select
  r.repo_group as repo_group,
  c.sha,
  v.actor_id,
  c.dup_created_at as created_at
from
  gha_repo_groups r,
  gha_commits c
cross join lateral
  (values
    ('actor', c.dup_actor_id, c.dup_actor_login),
    ('author', c.author_id, c.dup_author_login),
    ('committer', c.committer_id, c.dup_committer_login)
  ) v(role, actor_id, login)
where
  c.dup_repo_id = r.id
  and c.dup_repo_name = r.name
  and c.dup_created_at >= '{{from}}'
  and c.dup_created_at < '{{to}}'
  and (v.role = 'actor' or v.actor_id is not null)
  and (lower(v.login) {{exclude_bots}})
  and r.repo_group in (select repo_group_name from trepo_groups)
;
analyze cac_commits_{{rnd}};

create temp table cac_company_commits_{{rnd}} as
select
  c.repo_group,
  c.sha,
  c.actor_id,
  af.company_name as company
from
  cac_commits_{{rnd}} c,
  gha_actors_affiliations af
where
  c.actor_id = af.actor_id
  and af.dt_from <= c.created_at
  and af.dt_to > c.created_at
  and af.company_name != ''
  and af.company_name in (select companies_name from tcompanies)
;
analyze cac_company_commits_{{rnd}};

select
  concat('company;', sub.company, '`', sub.repo_group, ';committers,commits'),
  sub.committers,
  round(sub.commits::numeric / {{n}}, 2) as commits
from (
  select company,
    'all' as repo_group,
    round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) as commits,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)))) as committers
  from
    cac_company_commits_{{rnd}}
  group by
    company
  union select company,
    repo_group,
    round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) as commits,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)))) as committers
  from
    cac_company_commits_{{rnd}}
  group by
    company,
    repo_group
  union select 'All' as company,
    'all' as repo_group,
    round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) as commits,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)))) as committers
  from
    cac_commits_{{rnd}}
  union select 'All' as company,
    repo_group,
    round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) as commits,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)))) as committers
  from
    cac_commits_{{rnd}}
  group by
    repo_group
  ) sub
where
  sub.repo_group is not null
  and sub.committers > 0
;
