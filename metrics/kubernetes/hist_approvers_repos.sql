create temp table trepos_{{rnd}} as
select
  repo_name
from
  trepos
;
create index on trepos_{{rnd}}(repo_name);
analyze trepos_{{rnd}};

create temp table actors_country_{{rnd}} as
select
  id as actor_id,
  login,
  country_name
from
  gha_actors
where
  country_name is not null
  and country_name != ''
  and (lower(login) {{exclude_bots}})
;
create index on actors_country_{{rnd}}(actor_id);
create index on actors_country_{{rnd}}(login);
analyze actors_country_{{rnd}};

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
  e.created_at,
  e.actor_id,
  e.dup_actor_login as actor_login,
  e.dup_repo_name as repo_name
from
  gha_events e
join
  approves_matching_{{rnd}} m
on
  m.event_id = e.id
where
  (lower(e.dup_actor_login) {{exclude_bots}})
;
create index on approves_events_{{rnd}}(event_id);
create index on approves_events_{{rnd}}(actor_id);
create index on approves_events_{{rnd}}(repo_name);
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
where
  aa.dt_from <= '{{to}}'
  and aa.dt_to > '{{from}}'
;
create index on approves_affiliations_{{rnd}}(actor_id);
create index on approves_affiliations_{{rnd}}(dt_from);
create index on approves_affiliations_{{rnd}}(dt_to);
analyze approves_affiliations_{{rnd}};

create temp table approves_events_company_{{rnd}} as
select
  e.event_id,
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
create index on approves_events_company_{{rnd}}(repo_name);
analyze approves_events_company_{{rnd}};

create temp table approves_events_country_{{rnd}} as
select
  e.event_id,
  e.repo_name,
  coalesce(aid.country_name, alog.country_name) as country,
  coalesce(aid.login, alog.login) as actor,
  e.company
from
  approves_events_company_{{rnd}} e
left join
  actors_country_{{rnd}} aid
on
  aid.actor_id = e.actor_id
left join
  actors_country_{{rnd}} alog
on
  alog.login = e.actor_login
  and aid.actor_id is null
where
  coalesce(aid.country_name, alog.country_name) is not null
;
create index on approves_events_country_{{rnd}}(event_id);
create index on approves_events_country_{{rnd}}(repo_name);
create index on approves_events_country_{{rnd}}(country);
create index on approves_events_country_{{rnd}}(actor);
analyze approves_events_country_{{rnd}};

select
  metric,
  actor_and_company,
  approves
from (
  select
    'hdev_approves,' || e.repo_name || '_All' as metric,
    e.actor_login || '$$$' || e.company as actor_and_company,
    count(*) as approves
  from
    approves_events_company_{{rnd}} e
  join
    trepos_{{rnd}} tr
  on
    tr.repo_name = e.repo_name
  group by
    e.repo_name,
    e.actor_login,
    e.company

  union all

  select
    'hdev_approves,All_All' as metric,
    e.actor_login || '$$$' || e.company as actor_and_company,
    count(*) as approves
  from
    approves_events_company_{{rnd}} e
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
    'hdev_approves,' || c.repo_name || '_' || c.country as metric,
    c.actor || '$$$' || c.company as actor_and_company,
    count(*) as approves
  from
    approves_events_country_{{rnd}} c
  join
    trepos_{{rnd}} tr
  on
    tr.repo_name = c.repo_name
  group by
    c.repo_name,
    c.country,
    c.actor,
    c.company
) out
order by
  approves desc,
  metric asc,
  actor_and_company asc
;

