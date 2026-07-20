select
  sub.repo || '$$$' || sub.company || '$$$' || sub.github_id || '$$$' || sub.author_names || '$$$' || sub.author_emails || '$$$' || sub.country as data,
  sub.PRs as value
from (
  select
    r.repo_group as repo,
    aa.company_name as company,
    a.login as github_id,
    coalesce(a.country_name, '-') as country,
    coalesce(string_agg(distinct coalesce(an.name, '-'), ', '), '-') as author_names,
    coalesce(string_agg(distinct coalesce(ae.email, '-'), ', '), '-') as author_emails,
    count(distinct pr.id) as PRs
  from
    gha_pull_requests pr,
    gha_actors_affiliations aa,
    gha_repo_groups r,
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
    and pr.dup_repo_name = r.name
    and pr.dup_user_login = a.login
    -- and pr.dup_type = 'PullRequestEvent'
    -- and pr.state = 'open'
    and aa.company_name != ''
    and aa.company_name in (select companies_name from tcompanies)
    and r.repo_group is not null
    and {{period:pr.created_at}}
    and (lower(pr.dup_user_login) {{exclude_bots}})
  group by
    company,
    repo,
    github_id,
    country
  ) sub
;
