select count(*) as orphan_commit_roles
from gha_commits_roles r
join gha_commits c
  on c.sha = r.sha
 and c.event_id = r.event_id
where c.origin = 2;

select count(*) as orphan_commits_with_trailers_missing_roles
from gha_commits c
where c.origin = 2
  and c.message ~* '(?m)^(signed-off-by|co-authored-by|reviewed-by|acked-by):'
  and not exists (
    select 1
    from gha_commits_roles r
    where r.sha = c.sha
      and r.event_id = c.event_id
  );

select count(*) as origin2_with_real_sha_duplicate
from gha_commits o
where o.origin = 2
  and exists (
    select 1
    from gha_commits x
    where x.sha = o.sha
      and x.origin <> 2
  );

select count(*) as duplicate_origin2_sha_groups
from (
  select sha
  from gha_commits
  where origin = 2
  group by sha
  having count(*) > 1
) s;


