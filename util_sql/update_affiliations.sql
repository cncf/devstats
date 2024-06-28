with mult_ids_actors as (
  select
    login
  from
    gha_actors
  group by
    login
  having
    count(distinct id) > 1
), 

with_rolls as (
  select distinct
    a.login
  from
    mult_ids_actors m
  inner join
    gha_actors a
  on
    m.login = a.login
  inner join
    gha_actors_affiliations aa
  on
    a.id = aa.actor_id
),

ids_without_rolls as (
  select
    m.login,
    a.id
  from
    with_rolls m
  inner join
    gha_actors a
  on
    m.login = a.login
  left join
    gha_actors_affiliations aa
  on
    a.id = aa.actor_id
  group by
    m.login,
    a.id
  having
    count(distinct aa.actor_id) = 0
),

alternate_with_rolls as (
  select distinct
    m.login,
    a.id
  from
    ids_without_rolls m
  inner join
    gha_actors a
  on
    m.login = a.login
  inner join
    gha_actors_affiliations aa
  on
    a.id = aa.actor_id
  group by
    m.login,
    a.id
)

insert into gha_actors_affiliations(
  actor_id,
  company_name,
  dt_from,
  dt_to,
  original_company_name,
  source 
)
select
  iwr.id as actor_id,
  aa.company_name,
  aa.dt_from,
  aa.dt_to,
  aa.original_company_name,
  aa.source 
from
  ids_without_rolls iwr
inner join
  alternate_with_rolls awr
on
  iwr.login = awr.login
inner join
  gha_actors_affiliations aa
on
  aa.actor_id = awr.id
on conflict do nothing
