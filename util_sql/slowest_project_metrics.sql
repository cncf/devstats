WITH runs AS (
  SELECT
    proj,
    -- extract "... € <sqlfile> € ..." (works with /etc/... and ./metrics/...)
    (regexp_match(msg, '€\s*([^€]+?\.sql)\s*€'))[1] AS sql_file,
    (dt - run_dt) AS exec_time
  FROM gha_logs
  WHERE prog = 'calc_metric'
    AND msg LIKE 'Time(%'
    AND run_dt IS NOT NULL
    AND dt IS NOT NULL
),
norm AS (
  SELECT
    proj,
    -- metric name = basename(sql_file) without ".sql"
    regexp_replace(regexp_replace(sql_file, '^.*/', ''), '\.sql$', '') AS metric,
    exec_time
  FROM runs
  WHERE sql_file IS NOT NULL
)
SELECT
  proj,
  metric,
  count(*)          AS samples,
  avg(exec_time)    AS avg_exec_time,
  max(exec_time)    AS max_exec_time,
  min(exec_time)    AS min_exec_time
FROM norm
GROUP BY proj, metric
ORDER BY avg_exec_time DESC
LIMIT 200;

