#legacySQL
select
  org.id as org_id,
  org.login as org,
  repo.name as repo,
  repo.id as rid,
  min(created_at) as date_from,
  max(created_at) as date_to
from
--  [githubarchive:month.202501],
  [githubarchive:month.202508],
  [githubarchive:month.202507],
  [githubarchive:month.202506],
  [githubarchive:month.202505],
  [githubarchive:month.202504],
  [githubarchive:month.202503],
  [githubarchive:month.202502],
  [githubarchive:month.202501],
  [githubarchive:year.2024],
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
  org.id = (
    select
      org.id
    from
--      [githubarchive:month.202501],
      [githubarchive:month.202508],
      [githubarchive:month.202507],
      [githubarchive:month.202506],
      [githubarchive:month.202505],
      [githubarchive:month.202504],
      [githubarchive:month.202503],
      [githubarchive:month.202502],
      [githubarchive:month.202501],
      [githubarchive:year.2024],
      [githubarchive:year.2023],
      [githubarchive:year.2022],
      [githubarchive:year.2021],
      [githubarchive:year.2020],
      [githubarchive:year.2019]
      [githubarchive:year.2018],
      [githubarchive:year.2017],
      [githubarchive:year.2016],
      [githubarchive:year.2015],
      [githubarchive:year.2014]
    where
      org.login = '{{org}}'
    group by
      org.id,
      created_at
    order by
      created_at desc
    limit
      1
  )
group by
  org_id, org, repo, rid
order by
  date_from
;
