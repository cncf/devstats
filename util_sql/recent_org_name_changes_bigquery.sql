#legacySQL
select
  org.id as org_id,
  org.login as org,
  repo.name as repo,
  repo.id as rid,
  min(created_at) as date_from,
  max(created_at) as date_to
from
  [githubarchive:month.202410],
  [githubarchive:month.202409],
  [githubarchive:month.202408],
  [githubarchive:month.202407],
  [githubarchive:month.202406],
  [githubarchive:month.202405],
where
  org.id = (
    select
      org.id
    from
      [githubarchive:month.202410],
      [githubarchive:month.202409],
      [githubarchive:month.202408],
      [githubarchive:month.202407],
      [githubarchive:month.202406],
      [githubarchive:month.202405],
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
