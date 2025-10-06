select
  org.login as org,
  repo.name as repo,
  repo.id as rid,
  min(created_at) as date_from,
  max(created_at) as date_to
from (
  select
    org.login,
    repo.name,
    repo.id,
    created_at
  from
    [githubarchive:month.202509],
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
  group by
    org.login,
    repo.name,
    repo.id,
    created_at
  )
where
  repo.id in (
    select
      repo.id
    from
      [githubarchive:month.202509],
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
      lower(repo.name) like lower('{{org}}/%')
    group by
      repo.id
  )
group by
  org,
  repo,
  rid
order by
  date_from
;
