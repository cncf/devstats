create temp table nsk_{{rnd}} as
select
  ev.id,
  ev.actor_id,
  ev.repo_id,
  ev.dup_repo_name as repo_name,
  affs.company_name as company
from
  gha_events ev
left join
  gha_actors_affiliations affs
on
  ev.actor_id = affs.actor_id
  and affs.dt_from <= ev.created_at
  and affs.dt_to > ev.created_at
  and affs.company_name != ''
where
  ev.created_at >= '{{from}}'
  and ev.created_at < '{{to}}'
  and ev.type in (
    'PullRequestReviewCommentEvent', 'PushEvent', 'PullRequestEvent',
    'IssuesEvent', 'IssueCommentEvent', 'CommitCommentEvent', 'PullRequestReviewEvent'
  )
  and (lower(ev.dup_actor_login) {{exclude_bots}})
;
analyze nsk_{{rnd}};

select
  'nstats;All;comps,devs,unks' as name,
  count(distinct ev.company) as n_companies,
  count(distinct ev.actor_id) as n_authors,
  count(distinct ev.actor_id) filter (where ev.company is null) as n_unknown_authors
from
  nsk_{{rnd}} ev
union select sub.name,
  count(distinct sub.company_name) as n_companies,
  count(distinct sub.actor_id) as n_authors,
  count(distinct sub.actor_id) filter (where sub.company_name is null) as n_unknown_authors
from (
    select 'nstats;' || coalesce(ecf.repo_group, r.repo_group) || ';comps,devs,unks' as name,
    ev.company as company_name,
    ev.actor_id
  from
    gha_repos r,
    nsk_{{rnd}} ev
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = ev.id
  where
    r.name = ev.repo_name
    and r.id = ev.repo_id
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
drop table nsk_{{rnd}};
