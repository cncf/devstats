-- SET lock_timeout = '15minutes';

BEGIN;

-- Build reusable maps once
CREATE TEMP TABLE tmp_name_to_login AS
SELECT an.name, max(a.login) AS login
FROM gha_actors_names an
JOIN gha_actors a ON a.id = an.actor_id
GROUP BY an.name
HAVING count(DISTINCT a.login) = 1;

CREATE TEMP TABLE tmp_login_to_id AS
SELECT login, max(id) AS id          -- exact equivalent of ORDER BY id DESC LIMIT 1 per login
FROM gha_actors
GROUP BY login;

CREATE TEMP TABLE tmp_id_to_login AS
SELECT id, min(login) AS login       -- deterministic tie-break for duplicated ids
FROM gha_actors
GROUP BY id;

CREATE TEMP TABLE tmp_actor_email AS
SELECT DISTINCT ON (actor_id)
       actor_id, email
FROM gha_actors_emails
ORDER BY actor_id, origin DESC, email;

-- Helpful indexes on temp tables (optional; usually not needed but cheap)
CREATE INDEX ON tmp_name_to_login(name);
CREATE INDEX ON tmp_login_to_id(login);
CREATE INDEX ON tmp_id_to_login(id);
CREATE INDEX ON tmp_actor_email(actor_id);

-- 1) Fill dup_author_login from author_name (unique name->login)
UPDATE gha_commits c
SET dup_author_login = n.login
FROM tmp_name_to_login n
WHERE c.author_name <> ''
  AND c.author_name = n.name
  AND c.dup_author_login IS DISTINCT FROM n.login;

-- 2) Fill author_id from dup_author_login (highest id per login)
UPDATE gha_commits c
SET author_id = l.id
FROM tmp_login_to_id l
WHERE c.dup_author_login <> ''
  AND c.author_id IS NULL
  AND c.dup_author_login = l.login;

-- 3) Fill author_email (prefer origin=1, then stable tie-break)
UPDATE gha_commits c
SET author_email = e.email
FROM tmp_actor_email e
WHERE c.author_email = ''
  AND c.author_id IS NOT NULL
  AND c.author_id = e.actor_id;

-- 4) Backfill dup_author_login from author_id (dedup id->login)
UPDATE gha_commits c
SET dup_author_login = a.login
FROM tmp_id_to_login a
WHERE c.dup_author_login = ''
  AND c.author_id IS NOT NULL
  AND a.id = c.author_id;

-- 5) Backfill dup_committer_login from committer_id (dedup id->login)
UPDATE gha_commits c
SET dup_committer_login = a.login
FROM tmp_id_to_login a
WHERE c.dup_committer_login = ''
  AND c.committer_id IS NOT NULL
  AND a.id = c.committer_id;

-- 6) Mark actor names as used by commits as author_name
UPDATE gha_actors_names an
SET origin = 1
WHERE an.origin = 0
  AND EXISTS (
    SELECT 1
    FROM gha_commits c
    WHERE c.author_name = an.name
  );

COMMIT;

