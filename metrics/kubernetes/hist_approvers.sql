create temp table approves_matching_{{rnd}} as
select distinct
  event_id
from
  gha_texts
where
  {{period:created_at}}
  and event_id is not null
  and body ilike '%/approve%'
  and substring(body from '(?i)(?:^|\n|\r)\s*/(?:approve)\s*(?:\n|\r|$)') is not null
;
create index on approves_matching_{{rnd}}(event_id);
analyze approves_matching_{{rnd}};

create temp table approves_events_{{rnd}} as
select
  e.id as event_id,
  e.repo_id,
  e.dup_repo_name as repo_name,
  e.created_at,
  e.actor_id,
  e.dup_actor_login as actor_login
from
  gha_events e
join
  approves_matching_{{rnd}} m
on
  m.event_id = e.id
;
create index on approves_events_{{rnd}}(event_id);
create index on approves_events_{{rnd}}(actor_id);
create index on approves_events_{{rnd}}(repo_id, repo_name);
analyze approves_events_{{rnd}};

create temp table approves_actor_ids_{{rnd}} as
select distinct
  actor_id
from
  approves_events_{{rnd}}
where
  actor_id is not null
;
create index on approves_actor_ids_{{rnd}}(actor_id);
analyze approves_actor_ids_{{rnd}};

create temp table approves_affiliations_{{rnd}} as
select
  aa.actor_id,
  aa.company_name,
  aa.dt_from,
  aa.dt_to
from
  gha_actors_affiliations aa
join
  approves_actor_ids_{{rnd}} aid
on
  aid.actor_id = aa.actor_id
;
create index on approves_affiliations_{{rnd}}(actor_id);
create index on approves_affiliations_{{rnd}}(dt_from);
create index on approves_affiliations_{{rnd}}(dt_to);
analyze approves_affiliations_{{rnd}};

create temp table approves_events_company_{{rnd}} as
select
  e.event_id,
  e.repo_id,
  e.repo_name,
  e.created_at,
  e.actor_id,
  e.actor_login,
  coalesce(aa.company_name, '') as company
from
  approves_events_{{rnd}} e
left join
  approves_affiliations_{{rnd}} aa
on
  aa.actor_id = e.actor_id
  and aa.dt_from <= e.created_at
  and aa.dt_to > e.created_at
;
create index on approves_events_company_{{rnd}}(event_id);
create index on approves_events_company_{{rnd}}(actor_id);
create index on approves_events_company_{{rnd}}(repo_id, repo_name);
analyze approves_events_company_{{rnd}};

create temp table approves_events_repo_{{rnd}} as
select
  e.event_id,
  r.repo_group as repo_group_base
from
  approves_events_company_{{rnd}} e
join
  gha_repos r
on
  r.id = e.repo_id
  and r.name = e.repo_name
;
create index on approves_events_repo_{{rnd}}(event_id);
analyze approves_events_repo_{{rnd}};

create temp table approves_ecf_groups_{{rnd}} as
select distinct
  ecf.event_id,
  ecf.repo_group
from
  gha_events_commits_files ecf
join
  approves_events_repo_{{rnd}} er
on
  er.event_id = ecf.event_id
where
  ecf.repo_group is not null
;
create index on approves_ecf_groups_{{rnd}}(event_id);
create index on approves_ecf_groups_{{rnd}}(repo_group);
analyze approves_ecf_groups_{{rnd}};

create temp table approves_ecf_nonnull_event_ids_{{rnd}} as
select distinct
  event_id
from
  approves_ecf_groups_{{rnd}}
;
create index on approves_ecf_nonnull_event_ids_{{rnd}}(event_id);
analyze approves_ecf_nonnull_event_ids_{{rnd}};

create temp table approves_ecf_null_event_ids_{{rnd}} as
select distinct
  ecf.event_id
from
  gha_events_commits_files ecf
join
  approves_events_repo_{{rnd}} er
on
  er.event_id = ecf.event_id
where
  ecf.repo_group is null
;
create index on approves_ecf_null_event_ids_{{rnd}}(event_id);
analyze approves_ecf_null_event_ids_{{rnd}};

create temp table approves_event_repo_groups_{{rnd}} as
select
  event_id,
  repo_group
from
  approves_ecf_groups_{{rnd}}
union all
select
  er.event_id,
  er.repo_group_base as repo_group
from
  approves_events_repo_{{rnd}} er
left join
  approves_ecf_nonnull_event_ids_{{rnd}} en
on
  en.event_id = er.event_id
left join
  approves_ecf_null_event_ids_{{rnd}} ez
on
  ez.event_id = er.event_id
where
  er.repo_group_base is not null
  and (en.event_id is null or ez.event_id is not null)
;
create index on approves_event_repo_groups_{{rnd}}(event_id);
create index on approves_event_repo_groups_{{rnd}}(repo_group);
analyze approves_event_repo_groups_{{rnd}};

create temp table approves_events_country_{{rnd}} as
select
  e.event_id,
  a.country_name as country,
  a.login as actor,
  e.company
from
  approves_events_company_{{rnd}} e
join
  gha_actors a
on
  a.id = e.actor_id
where
  a.country_name is not null
  and a.country_name != ''
  and (lower(a.login) {{exclude_bots}})
;
create index on approves_events_country_{{rnd}}(event_id);
create index on approves_events_country_{{rnd}}(country);
create index on approves_events_country_{{rnd}}(actor);
analyze approves_events_country_{{rnd}};

select
  metric,
  actor_and_company,
  approves
from (
  select
    'hdev_approves,' || rg.repo_group || '_All' as metric,
    e.actor_login || '$$$' || e.company as actor_and_company,
    count(*) as approves
  from
    approves_events_company_{{rnd}} e
  join
    approves_event_repo_groups_{{rnd}} rg
  on
    rg.event_id = e.event_id
  where
    rg.repo_group is not null
    and (lower(e.actor_login) {{exclude_bots}})
  group by
    rg.repo_group,
    e.actor_login,
    e.company

  union all

  select
    'hdev_approves,All_All' as metric,
    e.actor_login || '$$$' || e.company as actor_and_company,
    count(*) as approves
  from
    approves_events_company_{{rnd}} e
  where
    (lower(e.actor_login) {{exclude_bots}})
  group by
    e.actor_login,
    e.company

  union all

  select
    'hdev_approves,All_' || c.country as metric,
    c.actor || '$$$' || c.company as actor_and_company,
    count(*) as approves
  from
    approves_events_country_{{rnd}} c
  group by
    c.country,
    c.actor,
    c.company

  union all

  select
    'hdev_approves,' || rg.repo_group || '_' || c.country as metric,
    c.actor || '$$$' || c.company as actor_and_company,
    count(*) as approves
  from
    approves_events_country_{{rnd}} c
  join
    approves_event_repo_groups_{{rnd}} rg
  on
    rg.event_id = c.event_id
  where
    rg.repo_group is not null
  group by
    rg.repo_group,
    c.country,
    c.actor,
    c.company
) out
order by
  approves desc,
  metric asc,
  actor_and_company asc
;

