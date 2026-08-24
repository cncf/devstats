create temp table ns_{{rnd}} as
select
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
;
analyze ns_{{rnd}};

select
  'nstats;All;comps,devs,unks' as name,
  count(distinct ev.company) as n_companies,
  count(distinct ev.actor_id) as n_authors,
  count(distinct ev.actor_id) filter (where ev.company is null) as n_unknown_authors
from
  ns_{{rnd}} ev
union select 'nstats;' || r.repo_group || ';comps,devs,unks' as name,
  count(distinct ev.company) as n_companies,
  count(distinct ev.actor_id) as n_authors,
  count(distinct ev.actor_id) filter (where ev.company is null) as n_unknown_authors
from
  gha_repo_groups r,
  ns_{{rnd}} ev
where
  r.name = ev.repo_name
  and r.id = ev.repo_id
  and r.repo_group is not null
group by
  r.repo_group
order by
  n_companies desc,
  n_authors desc,
  name asc
;
drop table ns_{{rnd}};
