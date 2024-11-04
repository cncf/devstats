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
  [githubarchive:month.202410],
  [githubarchive:month.202409],
  [githubarchive:month.202408],
  [githubarchive:month.202407],
  [githubarchive:month.202406],
  [githubarchive:month.202405],
  [githubarchive:month.202404],
  [githubarchive:month.202403],
  [githubarchive:month.202402],
  [githubarchive:month.202401],
  [githubarchive:year.2023],
  [githubarchive:year.2022],
  [githubarchive:year.2021],
  [githubarchive:year.2020],
  [githubarchive:year.2019],
  [githubarchive:year.2018],
  [githubarchive:year.2017],
  [githubarchive:year.2016],
  [githubarchive:year.2015],
  [githubarchive:year.2014]
where
  repo.id = (
    select
      repo.id
    from
--      TABLE_DATE_RANGE([githubarchive:day.], TIMESTAMP('2018-01-01'), TIMESTAMP('2019-08-01'))
      [githubarchive:month.202410],
      [githubarchive:month.202409],
      [githubarchive:month.202408],
      [githubarchive:month.202407],
      [githubarchive:month.202406],
      [githubarchive:month.202405],
      [githubarchive:month.202404],
      [githubarchive:month.202403],
      [githubarchive:month.202402],
      [githubarchive:month.202401],
      [githubarchive:year.2023],
      [githubarchive:year.2022],
      [githubarchive:year.2021],
      [githubarchive:year.2020],
      [githubarchive:year.2019],
      [githubarchive:year.2018],
      [githubarchive:year.2017],
      [githubarchive:year.2016],
      [githubarchive:year.2015],
      [githubarchive:year.2014]
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
