WITH runs AS (
  SELECT
    regexp_replace(
      regexp_replace((regexp_match(msg, '€\s*([^€]+?\.sql)\s*€'))[1], '^.*/', ''),
      '\.sql$',
      ''
    ) AS metric,
    (dt - run_dt) AS exec_time
  FROM gha_logs
  WHERE prog = 'calc_metric'
    AND msg LIKE 'Time(%'
    AND dt >= now() - interval '2 weeks'
    AND run_dt IS NOT NULL
    AND dt IS NOT NULL
),
agg AS (
  SELECT
    metric,
    count(*) AS samples,
    avg(exec_time) AS avg_exec_time,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY exec_time) AS median_exec_time,
    percentile_cont(0.95) WITHIN GROUP (ORDER BY exec_time) AS p95_exec_time,
    max(exec_time) AS max_exec_time
  FROM runs
  WHERE metric IS NOT NULL
  GROUP BY metric
)
SELECT
  metric,
  samples,
  avg_exec_time,
  median_exec_time,
  p95_exec_time,
  max_exec_time
FROM agg
WHERE samples >= 3
ORDER BY avg_exec_time DESC
LIMIT 30;

