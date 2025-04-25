#legacySQL
select
  org.login as org,
  repo.name as repo,
  repo.id as rid,
  org.id as oid,
  min(created_at) as date_from,
  max(created_at) as date_to
from
--  TABLE_DATE_RANGE([githubarchive:day.], TIMESTAMP('2018-01-01'), TIMESTAMP('2019-08-01'))
--  [githubarchive:month.202501],
  [githubarchive:month.202503],
  [githubarchive:month.202502],
  [githubarchive:month.202501],
where
  repo.id = (
    select
      repo.id
    from
--      TABLE_DATE_RANGE([githubarchive:day.], TIMESTAMP('2018-01-01'), TIMESTAMP('2019-08-01'))
--      [githubarchive:month.202501],
      [githubarchive:month.202503],
      [githubarchive:month.202502],
      [githubarchive:month.202501],
    where
      repo.name = '{{org_repo}}'
    group by
      repo.id,
      created_at
    order by
      created_at desc
    limit
      1
  )
group by
  org, repo, rid, oid
order by
  date_from
;
