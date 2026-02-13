SELECT
  p.dup_repo_name, p.dup_actor_login, p.dup_created_at,
  p.event_id, p.push_id, p.ref, p.head, p.befor, p.size
FROM gha_payloads p
WHERE p.dup_type = 'PushEvent'
  AND NOT EXISTS (
    SELECT 1
    FROM gha_commits c
    WHERE c.event_id = p.event_id
  )
ORDER BY p.dup_repo_name ASC, p.dup_created_at ASC, p.event_id ASC;
