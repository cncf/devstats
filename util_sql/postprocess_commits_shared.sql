BEGIN;

-- 1) Fill dup_author_login from author_name (unique name->login)
UPDATE gha_commits c
SET dup_author_login = n.login
FROM gha_map_name_to_login n
WHERE c.author_name <> ''
  AND c.author_name = n.name
  AND c.dup_author_login IS DISTINCT FROM n.login;

-- 2) Fill author_id from dup_author_login (highest id per login)
UPDATE gha_commits c
SET author_id = l.id
FROM gha_map_login_to_id l
WHERE c.dup_author_login <> ''
  AND c.author_id IS NULL
  AND c.dup_author_login = l.login;

-- 3) Fill author_email (prefer origin=1, then stable tie-break)
UPDATE gha_commits c
SET author_email = e.email
FROM gha_map_actor_email e
WHERE c.author_email = ''
  AND c.author_id IS NOT NULL
  AND c.author_id = e.actor_id;

-- 4) Backfill dup_author_login from author_id (dedup id->login)
UPDATE gha_commits c
SET dup_author_login = a.login
FROM gha_map_id_to_login a
WHERE c.dup_author_login = ''
  AND c.author_id IS NOT NULL
  AND a.id = c.author_id;

-- 5) Backfill dup_committer_login from committer_id (dedup id->login)
UPDATE gha_commits c
SET dup_committer_login = a.login
FROM gha_map_id_to_login a
WHERE c.dup_committer_login = ''
  AND c.committer_id IS NOT NULL
  AND a.id = c.committer_id;

COMMIT;
