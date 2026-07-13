-- Bounded rebuild of gha_issues_events_labels for a backfill window [from, to)  (PHASE 2).
--
-- Companion to postprocess_labels.sql (hourly: 1 month event-time window + ON CONFLICT DO NOTHING).
-- Use THIS for rows whose event time is older than that window. Delete-then-reinsert (NOT
-- insert-only): ghapi2db can delete and re-create artificial events, so stale/orphan generated rows must be
-- cleared before re-inserting. For THIS table the target created_at is inserted from
-- gha_issues_labels.dup_created_at (the event-time), so deleting by the target created_at range is both
-- dup-safe and orphan-safe: it removes every row in the window - including orphans whose source row was
-- deleted - and the re-insert then re-adds only the rows that currently exist in the window. Idempotent.
-- (This is why labels uses a target-range delete while gha_texts must delete by event_id: gha_texts stores
-- the source TEXT timestamp, not the event-time, so only an event_id delete matches what it re-inserts.)
--
-- Window from session settings devstats.postprocess_from / devstats.postprocess_to (set by `structure` from
-- GHA2DB_POSTPROCESS_FROM/_TO, or manually via `set devstats.postprocess_from=...`). Unset => safe no-op.
-- Simplest full alternative: truncate gha_issues_events_labels + run structure (see runbook).

with pp as (
  select
    nullif(current_setting('devstats.postprocess_from', true), '')::timestamp as pfrom,
    nullif(current_setting('devstats.postprocess_to', true), '')::timestamp as pto
)
delete from gha_issues_events_labels gel
using pp
where gel.created_at >= pp.pfrom
  and gel.created_at <  pp.pto
;

with pp as (
  select
    nullif(current_setting('devstats.postprocess_from', true), '')::timestamp as pfrom,
    nullif(current_setting('devstats.postprocess_to', true), '')::timestamp as pto
)
insert into gha_issues_events_labels(
  issue_id, event_id, label_id, label_name, created_at,
  -- repo_id, repo_name, actor_id, actor_login, type, issue_number
  repo_id, repo_name, actor_id, actor_login, type
)
select
  il.issue_id, il.event_id, lb.id, lb.name, il.dup_created_at,
  -- il.dup_repo_id, il.dup_repo_name, il.dup_actor_id, il.dup_actor_login, il.dup_type, il.dup_issue_number
  il.dup_repo_id, il.dup_repo_name, il.dup_actor_id, il.dup_actor_login, il.dup_type
from
  gha_issues_labels il,
  gha_labels lb,
  pp
where
  il.label_id = lb.id
  and il.dup_created_at >= pp.pfrom
  and il.dup_created_at <  pp.pto
on conflict do nothing
;
