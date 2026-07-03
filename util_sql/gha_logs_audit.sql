-- gha_logs_audit.sql  (PHASE 1 - raw data research: did the raw fetchers error?)
--
-- gha_logs lives in the *devstats* logs DB (NOT the project DB) and receives every tool's log line
-- (prog = binary name: gha2db, get_repos, ghapi2db, structure, gha2db_sync, ...; proj = project;
--  run_dt groups one invocation; dt = when the line was written; msg = the text).
-- This surfaces raw-fetch failures so you can tell "sync errored on these hours" from "upstream is thinner".
--
-- Usage (against the logs DB):
--   PG_DB=devstats psql devstats -v proj="'kubernetes'" -v since="'2025-07-01'" -f util_sql/gha_logs_audit.sql
-- Note: logs are periodically pruned (ClearDBLogs), so very old runs may be absent.

\set ON_ERROR_STOP on

\echo '== A. Runs per tool in window (distinct invocations, first/last activity) =='
select prog,
  count(distinct run_dt) as runs,
  count(*) as log_lines,
  min(dt) as first_dt, max(dt) as last_dt
from gha_logs
where proj = :proj and dt >= :since::timestamp
group by prog order by prog;

\echo '== B. Error/WARNING lines per tool per day (any decline of runs or spikes of errors is suspicious) =='
select date_trunc('day', dt) as day, prog, count(*) as error_lines
from gha_logs
where proj = :proj and dt >= :since::timestamp
  and msg ~* '(error|fatal|cannot|abort|gave up|abuse|api limit|rate limit|failed|warning|malformed|no data yet|not found)'
group by 1, 2 order by 1, 2;

\echo '== C. gha2db RAW GHArchive fetch/parse problems (missing hours, unmarshal, download give-ups) =='
select date_trunc('day', dt) as day,
  count(*) filter (where msg ~* 'gave up on')                 as gave_up_hours,
  count(*) filter (where msg ~* 'cannot unmarshal|unmarshal failed') as unmarshal_errors,
  count(*) filter (where msg ~* 'error http\.get')            as http_get_errors,
  count(*) filter (where msg ~* 'no data yet')                as no_data_yet,
  count(*) filter (where msg ~* 'retry\(')                    as retries
from gha_logs
where proj = :proj and prog = 'gha2db' and dt >= :since::timestamp
group by 1 order by 1;

\echo '== D. get_repos (commit enrichment) git failures per day =='
select date_trunc('day', dt) as day,
  count(*) filter (where msg ~* 'git-clone failed')       as clone_failed,
  count(*) filter (where msg ~* 'git_reset_pull\.sh failed') as reset_pull_failed,
  count(*) filter (where msg ~* 'git_loc\.sh failed')     as loc_failed,
  count(*) filter (where msg ~* 'git_files\.sh failed')   as files_failed
from gha_logs
where proj = :proj and prog = 'get_repos' and dt >= :since::timestamp
group by 1 order by 1;

\echo '== E. ghapi2db (issues/PRs API enrichment) problems per day =='
select date_trunc('day', dt) as day,
  count(*) filter (where msg ~* 'api limit reached|getratelimit call failed') as api_limit_aborts,
  count(*) filter (where msg ~* 'abuse detected')          as abuse_waits,
  count(*) filter (where msg ~* 'skipping event without type|skipping event type') as skipped_events,
  count(*) filter (where msg ~* 'not found')               as not_found,
  count(*) filter (where msg ~* 'no actor')                as no_actor_skips
from gha_logs
where proj = :proj and prog = 'ghapi2db' and dt >= :since::timestamp
group by 1 order by 1;

\echo '== F. Runs that look aborted/failed (contain aborting / gave up / fatal) - inspect these run_dt =='
select prog, run_dt, count(*) as lines, min(dt) as started, max(dt) as last_line
from gha_logs
where proj = :proj and dt >= :since::timestamp
  and msg ~* '(aborting|gave up|fatal)'
group by prog, run_dt order by run_dt desc
limit 100;

\echo '== G. Most recent 100 error/WARNING lines (raw text, for eyeballing) =='
select dt, prog, left(msg, 240) as msg
from gha_logs
where proj = :proj and dt >= :since::timestamp
  and msg ~* '(error|fatal|cannot|abort|gave up|abuse|api limit|failed|warning|malformed|no data yet)'
order by dt desc
limit 100;
