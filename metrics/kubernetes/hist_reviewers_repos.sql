create temp table trepos_{{rnd}} as
select distinct
  repo_name
from
  trepos
;
create index on trepos_{{rnd}}(repo_name);
analyze trepos_{{rnd}};

create temp table reviews_lbl_ids_{{rnd}} as
select
  min(event_id) as event_id
from
  gha_issues_events_labels
where
  {{period:created_at}}
  and label_name in ('lgtm', 'approved')
  and event_id is not null
group by
  issue_id
;
create index on reviews_lbl_ids_{{rnd}}(event_id);
analyze reviews_lbl_ids_{{rnd}};

create temp table reviews_txt_ids_{{rnd}} as
select distinct
  event_id
from
  gha_texts
where
  {{period:created_at}}
  and event_id is not null
  and (body ilike '%/lgtm%' or body ilike '%/approve%')
  and substring(body from '(?i)(?:^|\n|\r)\s*/(?:lgtm|approve)\s*(?:\n|\r|$)') is not null
;
create index on reviews_txt_ids_{{rnd}}(event_id);
analyze reviews_txt_ids_{{rnd}};

create temp table reviews_evt_ids_{{rnd}} as
select
  id as event_id
from
  gha_events
where
  {{period:created_at}}
  and type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent')
;
create index on reviews_evt_ids_{{rnd}}(event_id);
analyze reviews_evt_ids_{{rnd}};

create temp table reviews_ids_{{rnd}} as
select distinct
  event_id
from (
  select event_id from reviews_lbl_ids_{{rnd}}
  union all
  select event_id from reviews_txt_ids_{{rnd}}
  union all
  select event_id from reviews_evt_ids_{{rnd}}
) u
where
  event_id is not null
;
create index on reviews_ids_{{rnd}}(event_id);
analyze reviews_ids_{{rnd}};

create temp table reviews_events_{{rnd}} as
select
  e.id,
  e.actor_id,
  e.dup_actor_login,
  e.dup_repo_name as repo,
  e.created_at
from
  gha_events e
join
  reviews_ids_{{rnd}} i
on
  i.event_id = e.id
;
create index on reviews_events_{{rnd}}(id);
create index on reviews_events_{{rnd}}(actor_id);
create index on reviews_events_{{rnd}}(dup_actor_login);
create index on reviews_events_{{rnd}}(repo);
create index on reviews_events_{{rnd}}(created_at);
analyze reviews_events_{{rnd}};

create temp table reviews_actor_ids_{{rnd}} as
select distinct
  actor_id
from
  reviews_events_{{rnd}}
where
  actor_id is not null
;
create index on reviews_actor_ids_{{rnd}}(actor_id);
analyze reviews_actor_ids_{{rnd}};

create temp table reviews_actor_logins_{{rnd}} as
select distinct
  dup_actor_login as login
from
  reviews_events_{{rnd}}
where
  dup_actor_login is not null
  and dup_actor_login != ''
;
create index on reviews_actor_logins_{{rnd}}(login);
analyze reviews_actor_logins_{{rnd}};

create temp table reviews_bounds_{{rnd}} as
select
  min(created_at) as min_created_at,
  max(created_at) as max_created_at
from
  reviews_events_{{rnd}}
;
analyze reviews_bounds_{{rnd}};

create temp table reviews_aff_{{rnd}} as
select
  aa.actor_id,
  aa.company_name,
  aa.dt_from,
  aa.dt_to
from
  gha_actors_affiliations aa
join
  reviews_actor_ids_{{rnd}} aid
on
  aid.actor_id = aa.actor_id
join
  reviews_bounds_{{rnd}} b
on
  true
where
  b.min_created_at is not null
  and b.max_created_at is not null
  and aa.dt_from <= b.max_created_at
  and aa.dt_to > b.min_created_at
;
create index on reviews_aff_{{rnd}}(actor_id, dt_from, dt_to);
analyze reviews_aff_{{rnd}};

create temp table reviews_events_company_{{rnd}} as
select
  e.id,
  e.repo,
  e.actor_id,
  e.dup_actor_login,
  e.created_at,
  coalesce(aa.company_name, '') as company
from
  reviews_events_{{rnd}} e
left join
  reviews_aff_{{rnd}} aa
on
  aa.actor_id = e.actor_id
  and aa.dt_from <= e.created_at
  and aa.dt_to > e.created_at
;
create index on reviews_events_company_{{rnd}}(id);
create index on reviews_events_company_{{rnd}}(repo);
create index on reviews_events_company_{{rnd}}(actor_id);
create index on reviews_events_company_{{rnd}}(dup_actor_login);
analyze reviews_events_company_{{rnd}};

create temp table reviews_events_company_repo_{{rnd}} as
select
  ec.*
from
  reviews_events_company_{{rnd}} ec
join
  trepos_{{rnd}} tr
on
  tr.repo_name = ec.repo
;
create index on reviews_events_company_repo_{{rnd}}(repo);
create index on reviews_events_company_repo_{{rnd}}(dup_actor_login);
analyze reviews_events_company_repo_{{rnd}};

create temp table reviews_actors_country_{{rnd}} as
select
  id,
  login,
  country_name
from
  gha_actors
where
  country_name is not null
  and (lower(login) {{exclude_bots}})
  and (
    id in (select actor_id from reviews_actor_ids_{{rnd}})
    or login in (select login from reviews_actor_logins_{{rnd}})
  )
;
create index on reviews_actors_country_{{rnd}}(id);
create index on reviews_actors_country_{{rnd}}(login);
create index on reviews_actors_country_{{rnd}}(country_name);
analyze reviews_actors_country_{{rnd}};

create temp table reviews_country_rows_{{rnd}} as
select
  ec.id as id,
  ec.repo as repo,
  a.country_name as country,
  a.login as actor,
  ec.company as company
from
  reviews_events_company_{{rnd}} ec
join
  reviews_actors_country_{{rnd}} a
on
  a.id = ec.actor_id
union all
select
  ec.id as id,
  ec.repo as repo,
  a.country_name as country,
  a.login as actor,
  ec.company as company
from
  reviews_events_company_{{rnd}} ec
join
  reviews_actors_country_{{rnd}} a
on
  a.login = ec.dup_actor_login
where
  ec.actor_id is null
  or a.id <> ec.actor_id
;
create index on reviews_country_rows_{{rnd}}(repo);
create index on reviews_country_rows_{{rnd}}(country);
create index on reviews_country_rows_{{rnd}}(actor);
create index on reviews_country_rows_{{rnd}}(id);
analyze reviews_country_rows_{{rnd}};

select
  metric,
  actor_and_company,
  reviews
from (
  select
    'hdev_reviews,' || sub.repo || '_All' as metric,
    sub.actor || '$$$' || sub.company as actor_and_company,
    count(distinct sub.id) as reviews
  from (
    select
      repo,
      dup_actor_login as actor,
      company,
      id
    from
      reviews_events_company_repo_{{rnd}}
    where
      (lower(dup_actor_login) {{exclude_bots}})
  ) sub
  group by
    sub.repo,
    sub.actor,
    sub.company
  having
    count(distinct sub.id) >= 1

  union

  select
    'hdev_reviews,All_All' as metric,
    sub.actor || '$$$' || sub.company as actor_and_company,
    count(distinct sub.id) as reviews
  from (
    select
      dup_actor_login as actor,
      company,
      id
    from
      reviews_events_company_{{rnd}}
    where
      (lower(dup_actor_login) {{exclude_bots}})
  ) sub
  group by
    sub.actor,
    sub.company
  having
    count(distinct sub.id) >= 1

  union

  select
    'hdev_reviews,' || sub.repo || '_' || sub.country as metric,
    sub.actor || '$$$' || sub.company as actor_and_company,
    count(distinct sub.id) as reviews
  from (
    select
      cr.repo,
      cr.country,
      cr.actor,
      cr.company,
      cr.id
    from
      reviews_country_rows_{{rnd}} cr
    join
      trepos_{{rnd}} tr
    on
      tr.repo_name = cr.repo
    where
      cr.country is not null
  ) sub
  group by
    sub.country,
    sub.repo,
    sub.actor,
    sub.company
  having
    count(distinct sub.id) >= 1

  union

  select
    'hdev_reviews,All_' || sub.country as metric,
    sub.actor || '$$$' || sub.company as actor_and_company,
    count(distinct sub.id) as reviews
  from (
    select
      country,
      actor,
      company,
      id
    from
      reviews_country_rows_{{rnd}}
    where
      country is not null
  ) sub
  group by
    sub.country,
    sub.actor,
    sub.company
  having
    count(distinct sub.id) >= 1
) out
order by
  reviews desc,
  metric asc,
  actor_and_company asc
;

