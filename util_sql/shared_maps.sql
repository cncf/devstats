BEGIN;

TRUNCATE gha_map_name_to_login, gha_map_login_to_id, gha_map_id_to_login, gha_map_actor_email;

INSERT INTO gha_map_name_to_login(name, login)
SELECT an.name, max(a.login) AS login
FROM gha_actors_names an
JOIN gha_actors a ON a.id = an.actor_id
GROUP BY an.name
HAVING count(DISTINCT a.login) = 1;

INSERT INTO gha_map_login_to_id(login, id)
SELECT login, max(id) AS id
FROM gha_actors
GROUP BY login;

INSERT INTO gha_map_id_to_login(id, login)
SELECT id, min(login) AS login
FROM gha_actors
GROUP BY id;

INSERT INTO gha_map_actor_email(actor_id, email)
SELECT DISTINCT ON (actor_id)
       actor_id, email
FROM gha_actors_emails
ORDER BY actor_id, origin DESC, email;

COMMIT;

ANALYZE gha_map_name_to_login;
ANALYZE gha_map_login_to_id;
ANALYZE gha_map_id_to_login;
ANALYZE gha_map_actor_email;
