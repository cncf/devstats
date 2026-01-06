WITH runs AS (
  SELECT
    proj,
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
    regexp_replace(regexp_replace(sql_file, '^.*/', ''), '\.sql$', '') AS metric,
    exec_time
  FROM runs
  WHERE sql_file IS NOT NULL
),
pm AS (
  SELECT
    metric,
    proj,
    count(*)       AS samples,
    avg(exec_time) AS avg_exec_time
  FROM norm
  GROUP BY metric, proj
),
ranked AS (
  SELECT
    *,
    row_number() OVER (PARTITION BY metric ORDER BY avg_exec_time DESC) AS rnk
  FROM pm
),
overall AS (
  SELECT
    metric,
    count(*)       AS total_samples,
    avg(exec_time) AS avg_exec_time_all,
    max(exec_time) AS max_exec_time_all
  FROM norm
  GROUP BY metric
)
SELECT
  o.metric,
  o.total_samples,
  o.avg_exec_time_all,
  o.max_exec_time_all,
  r.proj        AS worst_proj,
  r.samples     AS worst_proj_samples,
  r.avg_exec_time AS worst_proj_avg
FROM overall o
JOIN ranked r
  ON r.metric = o.metric AND r.rnk = 1
ORDER BY o.avg_exec_time_all DESC
LIMIT 200;

