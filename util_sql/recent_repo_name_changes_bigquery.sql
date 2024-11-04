#legacySQL
select
  org.login as org,
  repo.name as repo,
  repo.id as rid,
  org.id as oid,
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
  repo.id = (
    select
      repo.id
    from
      [githubarchive:month.202410],
      [githubarchive:month.202409],
      [githubarchive:month.202408],
      [githubarchive:month.202407],
      [githubarchive:month.202406],
      [githubarchive:month.202405],
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
