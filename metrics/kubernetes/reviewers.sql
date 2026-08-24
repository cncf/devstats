create temp table rev_ids_{{rnd}} as
select min(event_id) as event_id
from
  gha_issues_events_labels
where
  created_at >= '{{from}}'
  and created_at < '{{to}}'
  and label_name in ('lgtm', 'approved')
group by
  issue_id
union select distinct event_id
from
  gha_texts
where
  created_at >= '{{from}}'
  and created_at < '{{to}}'
  and substring(body from '(?i)(?:^|\n|\r)\s*/(?:lgtm|approve)\s*(?:\n|\r|$)') is not null
  and (lower(actor_login) {{exclude_bots}})
union select distinct id as event_id
from
  gha_events
where
  created_at >= '{{from}}'
  and created_at < '{{to}}'
  and type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent')
  and (lower(dup_actor_login) {{exclude_bots}})
;
analyze rev_ids_{{rnd}};

create temp table rev_ev_{{rnd}} as
select
  e.id,
  e.actor_id,
  e.dup_actor_login as actor,
  e.repo_id,
  e.dup_repo_name as repo_name,
  e.created_at
from
  gha_events e
where
  e.id in (select event_id from rev_ids_{{rnd}})
;
analyze rev_ev_{{rnd}};

create temp table rev_aa_{{rnd}} as
select
  ev.id,
  ev.actor_id,
  ev.actor,
  ev.repo_id,
  ev.repo_name,
  aa.company_name as company
from
  rev_ev_{{rnd}} ev,
  gha_actors_affiliations aa
where
  aa.actor_id = ev.actor_id
  and aa.dt_from <= ev.created_at
  and aa.dt_to > ev.created_at
  and aa.company_name in (select companies_name from tcompanies)
;
analyze rev_aa_{{rnd}};

create temp table rev_act_{{rnd}} as
select
  ev.id,
  ev.actor as ev_actor,
  ev.repo_id,
  ev.repo_name,
  a.login as a_login,
  a.country_name as country
from
  rev_ev_{{rnd}} ev,
  gha_actors a
where
  (ev.actor_id = a.id or ev.actor = a.login)
  and a.country_name is not null
;
analyze rev_act_{{rnd}};

select 'cs;reviews_All_All_All;evs,acts' as metric,
  round(count(distinct ev.id) / {{n}}, 2) as evs,
  count(distinct ev.actor) as acts
from
  rev_ev_{{rnd}} ev
union all select 'cs;reviews_' || sub.repo_group || '_All_All;evs,acts' as metric,
  round(count(distinct sub.id) / {{n}}, 2) as evs,
  count(distinct sub.actor) as acts
from (
  select coalesce(ecf.repo_group, r.repo_group) as repo_group,
    ev.actor,
    ev.id
  from
    gha_repos r,
    rev_ev_{{rnd}} ev
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = ev.id
  where
    ev.repo_id = r.id
    and ev.repo_name = r.name
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
union all select 'cs;reviews_' || sub.repo_group || '_' || sub.country || '_All;evs,acts' as metric,
  round(count(distinct sub.id) / {{n}}, 2) as evs,
  count(distinct sub.actor) as acts
from (
  select coalesce(ecf.repo_group, r.repo_group) as repo_group,
    ev.country,
    ev.a_login as actor,
    ev.id
  from
    gha_repos r,
    rev_act_{{rnd}} ev
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = ev.id
  where
    ev.repo_id = r.id
    and ev.repo_name = r.name
  ) sub
where
  sub.repo_group is not null
  and sub.country is not null
group by
  sub.country,
  sub.repo_group
union all select 'cs;reviews_All_' || ev.country || '_All;evs,acts' as metric,
  round(count(distinct ev.id) / {{n}}, 2) as evs,
  count(distinct ev.ev_actor) as acts
from
  rev_act_{{rnd}} ev
group by
  ev.country
union all select 'cs;reviews_All_All_' || ev.company || ';evs,acts' as metric,
  round(count(distinct ev.id) / {{n}}, 2) as evs,
  count(distinct ev.actor) as acts
from
  rev_aa_{{rnd}} ev
group by
  ev.company
union all select 'cs;reviews_' || sub.repo_group || '_All_' || sub.company || ';evs,acts' as metric ,
  round(count(distinct sub.id) / {{n}}, 2) as evs,
  count(distinct sub.actor) as acts
from (
  select coalesce(ecf.repo_group, r.repo_group) as repo_group,
    ev.actor,
    ev.company,
    ev.id
  from
    gha_repos r,
    rev_aa_{{rnd}} ev
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = ev.id
  where
    ev.repo_id = r.id
    and ev.repo_name = r.name
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group,
  sub.company
union all select 'cs;reviews_' || sub.repo_group || '_' || sub.country || '_' || sub.company || ';evs,acts' as metric,
  round(count(distinct sub.id) / {{n}}, 2) as evs,
  count(distinct sub.actor) as acts
from (
  select coalesce(ecf.repo_group, r.repo_group) as repo_group,
    act.country,
    act.a_login as actor,
    ev.company,
    ev.id
  from
    gha_repos r,
    rev_aa_{{rnd}} ev
  join
    rev_act_{{rnd}} act
  on
    act.id = ev.id
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = ev.id
  where
    ev.repo_id = r.id
    and ev.repo_name = r.name
  ) sub
where
  sub.repo_group is not null
  and sub.country is not null
group by
  sub.country,
  sub.repo_group,
  sub.company
union all select 'cs;reviews_All_' || act.country || '_' || ev.company || ';evs,acts' as metric,
  round(count(distinct ev.id) / {{n}}, 2) as evs,
  count(distinct act.ev_actor) as acts
from
  rev_aa_{{rnd}} ev,
  rev_act_{{rnd}} act
where
  act.id = ev.id
group by
  act.country,
  ev.company
;
drop table rev_act_{{rnd}};
drop table rev_aa_{{rnd}};
drop table rev_ev_{{rnd}};
drop table rev_ids_{{rnd}};
