-- temp_buffers must be set before the session touches any temp table,
-- calc_metric reuses sessions across ranges, so ignore the error then
do $$ begin
  begin
    set temp_buffers = '1GB';
  exception when others then
    null;
  end;
end $$;

-- one period scan of commits expanded into the 3 roles (actor, author, committer)
-- via a lateral values list; the keep flag reproduces each role's null-id rule
create temp table commits_roles_{{rnd}} as
select
  r.repo_group,
  c.sha,
  c.dup_created_at,
  v.actor_id,
  v.actor_login
from
  gha_repo_groups r,
  gha_commits c
cross join lateral (
  values
    (c.dup_actor_id, c.dup_actor_login, true),
    (c.author_id, c.dup_author_login, c.author_id is not null),
    (c.committer_id, c.dup_committer_login, c.committer_id is not null)
) v(actor_id, actor_login, keep)
where
  c.dup_repo_id = r.id
  and c.dup_repo_name = r.name
  and c.dup_created_at >= '{{from}}'
  and c.dup_created_at < '{{to}}'
  and v.keep
;
analyze commits_roles_{{rnd}};

-- evaluate the ~100 like patterns of exclude_bots once per distinct login,
-- consumers below use a cheap hashed semi-join instead of the per-row patterns
create temp table commits_ok_logins_{{rnd}} as
select
  login
from (
  select distinct
    lower(actor_login) as login
  from
    commits_roles_{{rnd}}
  where
    actor_login is not null
) sub
where
  (login {{exclude_bots}})
;
create index on commits_ok_logins_{{rnd}}(login);
analyze commits_ok_logins_{{rnd}};

create temp table commits_data_{{rnd}} as
select distinct
  cr.repo_group,
  cr.sha,
  cr.actor_id,
  cr.actor_login,
  aa.company_name as company
from
  commits_roles_{{rnd}} cr
left join
  gha_actors_affiliations aa
on
  aa.actor_id = cr.actor_id
  and aa.dt_from <= cr.dup_created_at
  and aa.dt_to > cr.dup_created_at
where
  lower(cr.actor_login) in (select login from commits_ok_logins_{{rnd}})
;
create index on commits_data_{{rnd}}(actor_id);
create index on commits_data_{{rnd}}(repo_group);
analyze commits_data_{{rnd}};
-- metric_All_All_All: commits_RepoGroup_Country_Company
select 
  'cs;commits_All_All_All;evs,acts' as metric,
  round((hll_cardinality(hll_add_agg(hll_hash_text(sha))) / {{n}})::numeric, 2) as evs,
  round(hll_cardinality(hll_add_agg(hll_hash_text(actor_login)))) as acts
from 
  commits_data_{{rnd}}
union select  'cs;commits_' || repo_group || '_All_All;evs,acts' as metric,
  round((hll_cardinality(hll_add_agg(hll_hash_text(sha))) / {{n}})::numeric, 2) as evs,
  round(hll_cardinality(hll_add_agg(hll_hash_text(actor_login)))) as acts
from 
  commits_data_{{rnd}}
where
  repo_group is not null
group by
  repo_group
union select 'cs;commits_All_' || a.country_name || '_All;evs,acts' as metric,
  round((hll_cardinality(hll_add_agg(hll_hash_text(c.sha))) / {{n}})::numeric, 2) as evs,
  round(hll_cardinality(hll_add_agg(hll_hash_text(c.actor_login)))) as acts
from
  commits_data_{{rnd}} c,
  gha_actors a
where
  c.actor_id = a.id
  and a.country_name is not null
group by
  a.country_name
union select 'cs;commits_' || c.repo_group || '_' || a.country_name || '_All;evs,acts' as metric,
  round((hll_cardinality(hll_add_agg(hll_hash_text(c.sha))) / {{n}})::numeric, 2) as evs,
  round(hll_cardinality(hll_add_agg(hll_hash_text(c.actor_login)))) as acts
from
  commits_data_{{rnd}} c,
  gha_actors a
where
  c.actor_id = a.id
  and a.country_name is not null
  and c.repo_group is not null
group by
  a.country_name,
  c.repo_group
union select 'cs;commits_All_All_' || company || ';evs,acts' as metric,
  round((hll_cardinality(hll_add_agg(hll_hash_text(sha))) / {{n}})::numeric, 2) as evs,
  round(hll_cardinality(hll_add_agg(hll_hash_text(actor_login)))) as acts
from 
  commits_data_{{rnd}}
where
  company is not null
  and company in (select companies_name from tcompanies)
group by
  company
union select  'cs;commits_' || repo_group || '_All_' || company || ';evs,acts' as metric,
  round((hll_cardinality(hll_add_agg(hll_hash_text(sha))) / {{n}})::numeric, 2) as evs,
  round(hll_cardinality(hll_add_agg(hll_hash_text(actor_login)))) as acts
from 
  commits_data_{{rnd}}
where
  repo_group is not null
  and company is not null
  and company in (select companies_name from tcompanies)
group by
  repo_group,
  company
union select 'cs;commits_All_' || a.country_name || '_' || c.company || ';evs,acts' as metric,
  round((hll_cardinality(hll_add_agg(hll_hash_text(c.sha))) / {{n}})::numeric, 2) as evs,
  round(hll_cardinality(hll_add_agg(hll_hash_text(c.actor_login)))) as acts
from
  commits_data_{{rnd}} c,
  gha_actors a
where
  c.actor_id = a.id
  and a.country_name is not null
  and c.company is not null
  and c.company in (select companies_name from tcompanies)
group by
  a.country_name,
  c.company
union select 'cs;commits_' || c.repo_group || '_' || a.country_name || '_' || c.company || ';evs,acts' as metric,
  round((hll_cardinality(hll_add_agg(hll_hash_text(c.sha))) / {{n}})::numeric, 2) as evs,
  round(hll_cardinality(hll_add_agg(hll_hash_text(c.actor_login)))) as acts
from
  commits_data_{{rnd}} c,
  gha_actors a
where
  c.actor_id = a.id
  and a.country_name is not null
  and c.repo_group is not null
  and c.company is not null
  and c.company in (select companies_name from tcompanies)
group by
  a.country_name,
  c.repo_group,
  c.company
/*
order by
  acts desc,
  evs desc
*/
;
