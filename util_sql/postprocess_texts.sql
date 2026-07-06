-- GitHub / GH Archive event ids are NO LONGER globally monotonic: the pre-2025-10-08
-- id sequence ended at ~55,792,155,417 and all later events use a new, LOWER sequence
-- (~3.9e9 right after the switch, ~1.44e10 by 2026-07) that overlaps the historical
-- 2016-2019 id range; pre-2015 events carry negative (hash-synthesized) ids. Any
-- max(event_id) watermark is therefore permanently above every new real event id and
-- silently skips ALL new rows forever (this froze real-event texts fleet-wide from the
-- last full rebuild, ~2025-12-19..24).
--
-- So: no id watermarks. Two idempotent, restart-safe statements:
--   1) insert source rows whose EVENT time (dup_created_at) is newer than
--      max(gha_texts.created_at) minus a 1 month safety window and that are not yet
--      present (anti-join on event_id, backed by texts_event_id_idx);
--   2) insert sync-range rows (event_id >= 329900000000000) with no time window -
--      a small static set (e.g. the 2018-07 snapshot: 2,040 gha_issues + 412
--      gha_pull_requests rows) whose event times are old; the anti-join keeps
--      re-processing them free.
-- Re-running with the same input inserts nothing and only scans the 1-month candidate
-- window plus the tiny sync range. On an empty (truncated) table the cutoff collapses
-- to 1900-01-01, so a plain `structure` run still performs a FULL rebuild. Source rows
-- whose event time is older than the window (deep ghapi2db backfills) are handled by
-- postprocess_texts_range.sql via GHA2DB_POSTPROCESS_FROM/TO.
with cutoff as (
  select coalesce(max(created_at), '1900-01-01'::timestamp) - interval '1 month' as dt
  from
    gha_texts
)
insert into gha_texts(
  event_id, body, created_at, repo_id, repo_name, actor_id, actor_login, type
)
select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_comments, cutoff
where
  body != ''
  and dup_created_at >= cutoff.dt
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_comments.event_id
  )
union select
  event_id, message, dup_created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_commits, cutoff
where
  message != ''
  and dup_created_at >= cutoff.dt
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_commits.event_id
  )
union select
  event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_issues, cutoff
where
  title != ''
  and dup_created_at >= cutoff.dt
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_issues.event_id
  )
union select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_issues, cutoff
where
  body != ''
  and dup_created_at >= cutoff.dt
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_issues.event_id
  )
union select
  event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_pull_requests, cutoff
where
  title != ''
  and dup_created_at >= cutoff.dt
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_pull_requests.event_id
  )
union select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_pull_requests, cutoff
where
  body != ''
  and dup_created_at >= cutoff.dt
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_pull_requests.event_id
  )
union select
  event_id, body, submitted_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_reviews, cutoff
where
  body != ''
  and dup_created_at >= cutoff.dt
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_reviews.event_id
  )
;

-- Sync-range rows (event_id >= 329900000000000): no time window - see header comment.
insert into gha_texts(
  event_id, body, created_at, repo_id, repo_name, actor_id, actor_login, type
)
select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_comments
where
  body != ''
  and event_id >= 329900000000000
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_comments.event_id
  )
union select
  event_id, message, dup_created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_commits
where
  message != ''
  and event_id >= 329900000000000
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_commits.event_id
  )
union select
  event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_issues
where
  title != ''
  and event_id >= 329900000000000
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_issues.event_id
  )
union select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_issues
where
  body != ''
  and event_id >= 329900000000000
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_issues.event_id
  )
union select
  event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_pull_requests
where
  title != ''
  and event_id >= 329900000000000
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_pull_requests.event_id
  )
union select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_pull_requests
where
  body != ''
  and event_id >= 329900000000000
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_pull_requests.event_id
  )
union select
  event_id, body, submitted_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_reviews
where
  body != ''
  and event_id >= 329900000000000
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_reviews.event_id
  )
;
