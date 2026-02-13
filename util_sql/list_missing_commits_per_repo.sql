-- clear && k exec -in devstats-prod devstats-postgres-0 -c devstats-postgres -- psql allprj < util_sql/list_missing_commits_per_repo.sql
SELECT
  p.dup_repo_id,
  p.dup_repo_name,
  COUNT(*) AS missing_push_events,
  MIN(p.dup_created_at) AS missing_since,
  MAX(p.dup_created_at) AS missing_until,
  (MAX(p.dup_created_at) - MIN(p.dup_created_at)) AS span
FROM gha_payloads p
WHERE p.dup_type = 'PushEvent'
  AND NOT EXISTS (
    SELECT 1
    FROM gha_commits c
    WHERE c.event_id = p.event_id
  )
GROUP BY
  p.dup_repo_id, p.dup_repo_name
ORDER BY
  missing_push_events DESC,
  span DESC;

