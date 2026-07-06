-- GitHub / GH Archive event ids are NO LONGER globally monotonic: the pre-2025-10-08
-- id sequence ended at ~55,792,123,888 and all later events use a new, LOWER sequence
-- (~6.4e9 in 2025-11, growing ~1e9/month). Any max(event_id) watermark is therefore
-- permanently above every new real event id and silently skips ALL new rows forever
-- (this froze real-event texts fleet-wide from the last full rebuild, ~2025-12-19..24).
--
-- So: no id watermarks. Insert source rows whose EVENT time (dup_created_at) is newer
-- than max(gha_texts.created_at) minus a 7 day safety window and that are not yet
-- present (anti-join on event_id, backed by texts_event_id_idx). Re-running is
-- idempotent. On an empty (truncated) table the cutoff collapses to 1900-01-01, so a
-- plain `structure` run still performs a FULL rebuild. Source rows whose event time is
-- older than the window (deep ghapi2db backfills) are handled by
-- postprocess_texts_range.sql via GHA2DB_POSTPROCESS_FROM/TO.
with cutoff as (
  select coalesce(max(created_at), '1900-01-01'::timestamp) - interval '7 days' as dt
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
