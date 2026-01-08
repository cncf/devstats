create temp table reviews_label_event_ids_{{rnd}} as
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
create index on reviews_label_event_ids_{{rnd}}(event_id);
analyze reviews_label_event_ids_{{rnd}};

create temp table reviews_matching_text_event_ids_{{rnd}} as
select distinct
  event_id
from
  gha_texts
where
  {{period:created_at}}
  and event_id is not null
  and (
    body ilike '%/lgtm%'
    or body ilike '%/approve%'
  )
  and substring(body from '(?i)(?:^|\n|\r)\s*/(?:lgtm|approve)\s*(?:\n|\r|$)') is not null
;
create index on reviews_matching_text_event_ids_{{rnd}}(event_id);
analyze reviews_matching_text_event_ids_{{rnd}};

create temp table reviews_review_event_ids_{{rnd}} as
select
  id as event_id
from
  gha_events
where
  {{period:created_at}}
  and type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent')
;
create index on reviews_review_event_ids_{{rnd}}(event_id);
analyze reviews_review_event_ids_{{rnd}};

create temp table reviews_action_event_ids_{{rnd}} as
select distinct
  event_id
from (
  select event_id from reviews_label_event_ids_{{rnd}}
  union all
  select event_id from reviews_matching_text_event_ids_{{rnd}}
  union all
  select event_id from reviews_review_event_ids_{{rnd}}
) u
where
  event_id is not null
;
create index on reviews_action_event_ids_{{rnd}}(event_id);
analyze reviews_action_event_ids_{{rnd}};

create temp table reviews_events_{{rnd}} as
select
  e.id as event_id,
  e.created_at,
  e.actor_id,
  e.dup_actor_login,
  e.repo_id,
  e.dup_repo_name as repo_name
from
  gha_events e
join
  reviews_action_event_ids_{{rnd}} ids
on
  ids.event_id = e.id
;
create index on reviews_events_{{rnd}}(event_id);
create index on reviews_events_{{rnd}}(actor_id);
create index on reviews_events_{{rnd}}(dup_actor_login);
create index on reviews_events_{{rnd}}(repo_id, repo_name);
create index on reviews_events_{{rnd}}(created_at);
analyze reviews_events_{{rnd}};

create temp table reviews_event_actor_ids_{{rnd}} as
select distinct
  actor_id
from
  reviews_events_{{rnd}}
where
  actor_id is not null
;
create index on reviews_event_actor_ids_{{rnd}}(actor_id);
analyze reviews_event_actor_ids_{{rnd}};

create temp table reviews_event_logins_{{rnd}} as
select distinct
  dup_actor_login as login
from
  reviews_events_{{rnd}}
where
  dup_actor_login is not null
  and dup_actor_login != ''
;
create index on reviews_event_logins_{{rnd}}(login);
analyze reviews_event_logins_{{rnd}};

create temp table reviews_affiliations_{{rnd}} as
select
  aa.actor_id,
  aa.company_name,
  aa.dt_from,
  aa.dt_to
from
  gha_actors_affiliations aa
join
  reviews_event_actor_ids_{{rnd}} aid
on
  aid.actor_id = aa.actor_id
where
  aa.dt_from <= {{to}}
  and aa.dt_to > {{from}}
;
create index on reviews_affiliations_{{rnd}}(actor_id);
create index on reviews_affiliations_{{rnd}}(dt_from);
create index on reviews_affiliations_{{rnd}}(dt_to);
analyze reviews_affiliations_{{rnd}};

create temp table reviews_events_company_{{rnd}} as
select
  e.event_id,
  e.created_at,
  e.actor_id,
  e.dup_actor_login,
  e.repo_id,
  e.repo_name,
  coalesce(aa.company_name, '') as company
from
  reviews_events_{{rnd}} e
left join
  reviews_affiliations_{{rnd}} aa
on
  aa.actor_id = e.actor_id
  and aa.dt_from <= e.created_at
  and aa.dt_to > e.created_at
;
create index on reviews_events_company_{{rnd}}(event_id);
create index on reviews_events_company_{{rnd}}(dup_actor_login);
create index on reviews_events_company_{{rnd}}(actor_id);
create index on reviews_events_company_{{rnd}}(repo_id, repo_name);
analyze reviews_events_company_{{rnd}};

create temp table reviews_events_repo_{{rnd}} as
select
  e.event_id,
  r.repo_group as repo_group_repo
from
  reviews_events_{{rnd}} e
join
  gha_repos r
on
  r.id = e.repo_id
  and r.name = e.repo_name
;
create index on reviews_events_repo_{{rnd}}(event_id);
create index on reviews_events_repo_{{rnd}}(repo_group_repo);
analyze reviews_events_repo_{{rnd}};

create temp table reviews_ecf_event_{{rnd}} as
select
  ecf.event_id,
  ecf.repo_group
from
  gha_events_commits_files ecf
join
  reviews_events_repo_{{rnd}} er
on
  er.event_id = ecf.event_id
;
create index on reviews_ecf_event_{{rnd}}(event_id);
create index on reviews_ecf_event_{{rnd}}(repo_group);
analyze reviews_ecf_event_{{rnd}};

create temp table reviews_ecf_nonnull_{{rnd}} as
select distinct
  event_id,
  repo_group
from
  reviews_ecf_event_{{rnd}}
where
  repo_group is not null
;
create index on reviews_ecf_nonnull_{{rnd}}(event_id);
create index on reviews_ecf_nonnull_{{rnd}}(repo_group);
analyze reviews_ecf_nonnull_{{rnd}};

create temp table reviews_ecf_flags_{{rnd}} as
select
  event_id,
  bool_or(repo_group is null) as has_null_group
from
  reviews_ecf_event_{{rnd}}
group by
  event_id
;
create index on reviews_ecf_flags_{{rnd}}(event_id);
analyze reviews_ecf_flags_{{rnd}};

create temp table reviews_event_repo_groups_{{rnd}} as
select distinct
  event_id,
  repo_group
from (
  select
    event_id,
    repo_group
  from
    reviews_ecf_nonnull_{{rnd}}
  union all
  select
    er.event_id,
    er.repo_group_repo as repo_group
  from
    reviews_events_repo_{{rnd}} er
  left join
    reviews_ecf_flags_{{rnd}} f
  on
    f.event_id = er.event_id
  where
    er.repo_group_repo is not null
    and (f.event_id is null or f.has_null_group)
) x
where
  repo_group is not null
;
create index on reviews_event_repo_groups_{{rnd}}(event_id);
create index on reviews_event_repo_groups_{{rnd}}(repo_group);
analyze reviews_event_repo_groups_{{rnd}};

create temp table reviews_actor_candidates_{{rnd}} as
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
    id in (select actor_id from reviews_event_actor_ids_{{rnd}})
    or login in (select login from reviews_event_logins_{{rnd}})
  )
;
create index on reviews_actor_candidates_{{rnd}}(id);
create index on reviews_actor_candidates_{{rnd}}(login);
analyze reviews_actor_candidates_{{rnd}};

create temp table reviews_events_country_{{rnd}} as
select
  e.event_id,
  a.country_name as country,
  a.login as actor,
  e.actor_id
from
  reviews_events_{{rnd}} e
join
  reviews_actor_candidates_{{rnd}} a
on
  a.id = e.actor_id
union all
select
  e.event_id,
  a.country_name as country,
  a.login as actor,
  e.actor_id
from
  reviews_events_{{rnd}} e
join
  reviews_actor_candidates_{{rnd}} a
on
  a.login = e.dup_actor_login
where
  e.actor_id is null
  or a.id <> e.actor_id
;
create index on reviews_events_country_{{rnd}}(event_id);
create index on reviews_events_country_{{rnd}}(country);
create index on reviews_events_country_{{rnd}}(actor);
analyze reviews_events_country_{{rnd}};

select
  metric,
  actor_and_company,
  reviews
from (
  select
    'hdev_reviews,' || rg.repo_group || '_All' as metric,
    ec.dup_actor_login || '$$$' || ec.company as actor_and_company,
    count(distinct rg.event_id) as reviews
  from
    reviews_event_repo_groups_{{rnd}} rg
  join
    reviews_events_company_{{rnd}} ec
  on
    ec.event_id = rg.event_id
  where
    rg.repo_group is not null
    and (lower(ec.dup_actor_login) {{exclude_bots}})
  group by
    rg.repo_group,
    ec.dup_actor_login,
    ec.company
  having
    count(distinct rg.event_id) >= 1

  union

  select
    'hdev_reviews,All_All' as metric,
    ec.dup_actor_login || '$$$' || ec.company as actor_and_company,
    count(distinct ec.event_id) as reviews
  from
    reviews_events_company_{{rnd}} ec
  where
    (lower(ec.dup_actor_login) {{exclude_bots}})
  group by
    ec.dup_actor_login,
    ec.company
  having
    count(distinct ec.event_id) >= 1

  union

  select
    'hdev_reviews,' || rg.repo_group || '_' || c.country as metric,
    c.actor || '$$$' || ec.company as actor_and_company,
    count(distinct rg.event_id) as reviews
  from
    reviews_event_repo_groups_{{rnd}} rg
  join
    reviews_events_country_{{rnd}} c
  on
    c.event_id = rg.event_id
  join
    reviews_events_company_{{rnd}} ec
  on
    ec.event_id = rg.event_id
  where
    rg.repo_group is not null
    and c.country is not null
  group by
    c.country,
    rg.repo_group,
    c.actor,
    ec.company
  having
    count(distinct rg.event_id) >= 1

  union

  select
    'hdev_reviews,All_' || c.country as metric,
    c.actor || '$$$' || ec.company as actor_and_company,
    count(distinct c.event_id) as reviews
  from
    reviews_events_country_{{rnd}} c
  join
    reviews_events_company_{{rnd}} ec
  on
    ec.event_id = c.event_id
  where
    c.country is not null
  group by
    c.country,
    c.actor,
    ec.company
  having
    count(distinct c.event_id) >= 1
) out
order by
  reviews desc,
  metric asc,
  actor_and_company asc
;

