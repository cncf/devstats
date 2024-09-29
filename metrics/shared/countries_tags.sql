with data as (
  select
    a.country_name,
    count(distinct e.id) as cnt
  from
    gha_actors a
  left join
    gha_events e
  on
    e.actor_id = a.id
  where
    a.country_name is not null
    and a.country_name != ''
  group by
    a.country_name
  union select 'None', 0
  where (
    select count(country_name)
    from
      gha_actors
    where
      country_name is not null
      and country_name != ''
    ) = 0
)
select
  country_name
from
  data
order by
  cnt desc,
  country_name asc
;
