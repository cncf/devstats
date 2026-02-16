select dup_actor_id, dup_actor_login, author_id, dup_author_login, author_name, author_email, committer_id, dup_committer_login, committer_name, committer_email from gha_commits where dup_created_at > '2025-10-09';
select * from gha_commits_roles where sha in (select sha from gha_commits where dup_created_at > '2025-10-09');
select sha, event_id, role, count(*) as n
from gha_commits_roles where sha in (select sha from gha_commits where dup_created_at > '2025-10-09')
group by sha, event_id, role
having count(*) > 1
order by role asc, n desc;
