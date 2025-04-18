select
  aa.company_name as company,
  coalesce(r.repo_group, 'Other') as repo,
  a.login as github_id,
  coalesce(string_agg(distinct coalesce(an.name, '-'), ', '), '-') as author_names,
  coalesce(string_agg(distinct coalesce(ae.email, '-'), ', '), '-') as author_emails,
  count(distinct pr.id) as PRs
from
  gha_pull_requests pr,
  gha_actors_affiliations aa,
  gha_repos r,
  gha_actors a
left join
  gha_actors_names an
on
  an.actor_id = a.id
left join
  gha_actors_emails ae
on
  ae.actor_id = a.id
where
  aa.actor_id = pr.user_id
  and aa.actor_id = a.id
  and aa.dt_from <= pr.created_at
  and aa.dt_to > pr.created_at
  and pr.dup_repo_id = r.id
  and pr.created_at >= now() - '{{ago}}'::interval
  and lower(aa.company_name) in ({{companies}})
group by
  company,
  repo,
  github_id
order by
  company asc,
  repo asc,
  PRs desc
;
