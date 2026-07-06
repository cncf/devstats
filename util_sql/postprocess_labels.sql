-- GitHub / GH Archive event ids are NO LONGER globally monotonic: the pre-2025-10-08
-- id sequence ended at ~55,792,155,417 and all later events use a new, LOWER sequence
-- (~3.9e9 right after the switch, ~1.44e10 by 2026-07) that overlaps the historical
-- 2016-2019 id range; pre-2015 events carry negative (hash-synthesized) ids. Any
-- max(event_id) watermark is therefore permanently above every new real event id and
-- silently skips ALL new rows forever (this froze real-event labels fleet-wide from
-- the last full rebuild, ~2025-12-19..24).
--
-- So: no id watermarks. Two idempotent, restart-safe statements; the primary key
-- (issue_id, event_id, label_id) + ON CONFLICT DO NOTHING makes re-runs free:
--   1) insert source rows whose EVENT time (dup_created_at) is newer than
--      max(gha_issues_events_labels.created_at) minus a 1 month safety window;
--   2) insert sync-range rows (event_id >= 329900000000000) with no time window -
--      a small static set (e.g. the 2018-07 snapshot: 12,990 gha_issues_labels rows)
--      whose event times are old.
-- Re-running with the same input inserts nothing and only scans the 1-month candidate
-- window plus the tiny sync range. On an empty (truncated) table the cutoff collapses
-- to 1900-01-01, so a plain `structure` run still performs a FULL rebuild. Source rows
-- whose event time is older than the window (deep ghapi2db backfills) are handled by
-- postprocess_labels_range.sql via GHA2DB_POSTPROCESS_FROM/TO.
with cutoff as (
  select coalesce(max(created_at), '1900-01-01'::timestamp) - interval '1 month' as dt
  from
    gha_issues_events_labels
)
insert into gha_issues_events_labels(
  issue_id, event_id, label_id, label_name, created_at,
  repo_id, repo_name, actor_id, actor_login, type, issue_number
)
select
  il.issue_id, il.event_id, lb.id, lb.name, il.dup_created_at,
  il.dup_repo_id, il.dup_repo_name, il.dup_actor_id, il.dup_actor_login, il.dup_type, il.dup_issue_number
from
  gha_issues_labels il,
  gha_labels lb,
  cutoff
where
  il.label_id = lb.id
  and il.dup_created_at >= cutoff.dt
on conflict do nothing
;

-- Sync-range rows (event_id >= 329900000000000): no time window - see header comment.
insert into gha_issues_events_labels(
  issue_id, event_id, label_id, label_name, created_at,
  repo_id, repo_name, actor_id, actor_login, type, issue_number
)
select
  il.issue_id, il.event_id, lb.id, lb.name, il.dup_created_at,
  il.dup_repo_id, il.dup_repo_name, il.dup_actor_id, il.dup_actor_login, il.dup_type, il.dup_issue_number
from
  gha_issues_labels il,
  gha_labels lb
where
  il.label_id = lb.id
  and il.event_id >= 329900000000000
on conflict do nothing
;
