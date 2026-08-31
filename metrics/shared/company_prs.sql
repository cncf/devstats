CREATE TEMP TABLE cpr_aff_{{rnd}} AS
SELECT DISTINCT
  p.pr_id,
  p.actor_id,
  p.repo,
  aa.company_name AS company,
  a.login AS github_id,
  coalesce(a.country_name, '-') AS country
FROM (
  SELECT DISTINCT
    pr.id AS pr_id,
    pr.user_id AS actor_id,
    pr.dup_user_login AS github_id,
    pr.created_at,
    r.repo_group AS repo
  FROM
    gha_pull_requests pr
  JOIN
    gha_repo_groups r
  ON
    r.id = pr.dup_repo_id
    AND r.name = pr.dup_repo_name
  WHERE
    r.repo_group IS NOT NULL
    AND {{period:pr.created_at}}
    AND (lower(pr.dup_user_login) {{exclude_bots}})
) p
JOIN
  gha_actors a
ON
  a.id = p.actor_id
  AND a.login = p.github_id
JOIN
  gha_actors_affiliations aa
ON
  aa.actor_id = p.actor_id
  AND aa.dt_from <= p.created_at
  AND aa.dt_to > p.created_at
WHERE
  aa.company_name <> ''
  AND EXISTS (
    SELECT 1
    FROM tcompanies tc
    WHERE tc.companies_name = aa.company_name
  )
;

CREATE INDEX cpr_aff_group_{{rnd}}
ON cpr_aff_{{rnd}}(repo, company, github_id, country, pr_id);

CREATE INDEX cpr_aff_actor_{{rnd}}
ON cpr_aff_{{rnd}}(actor_id, repo, company, github_id, country);

ANALYZE cpr_aff_{{rnd}};

select
  g.repo || '$$$' ||
  g.company || '$$$' ||
  g.github_id || '$$$' ||
  n.author_names || '$$$' ||
  e.author_emails || '$$$' ||
  g.country AS data,
  g.prs AS value
FROM (
  SELECT
    repo,
    company,
    github_id,
    country,
    count(DISTINCT pr_id) AS prs
  FROM
    cpr_aff_{{rnd}}
  GROUP BY
    repo,
    company,
    github_id,
    country
) g
JOIN (
  SELECT
    ga.repo,
    ga.company,
    ga.github_id,
    ga.country,
    coalesce(
      string_agg(DISTINCT coalesce(an.name, '-'), ', '),
      '-'
    ) AS author_names
  FROM (
    SELECT DISTINCT
      repo,
      company,
      github_id,
      country,
      actor_id
    FROM
      cpr_aff_{{rnd}}
  ) ga
  LEFT JOIN
    gha_actors_names an
  ON
    an.actor_id = ga.actor_id
  GROUP BY
    ga.repo,
    ga.company,
    ga.github_id,
    ga.country
) n
USING
  (repo, company, github_id, country)
JOIN (
  SELECT
    ga.repo,
    ga.company,
    ga.github_id,
    ga.country,
    coalesce(
      string_agg(DISTINCT coalesce(ae.email, '-'), ', '),
      '-'
    ) AS author_emails
  FROM (
    SELECT DISTINCT
      repo,
      company,
      github_id,
      country,
      actor_id
    FROM
      cpr_aff_{{rnd}}
  ) ga
  LEFT JOIN
    gha_actors_emails ae
  ON
    ae.actor_id = ga.actor_id
  GROUP BY
    ga.repo,
    ga.company,
    ga.github_id,
    ga.country
) e
USING
  (repo, company, github_id, country)
;
