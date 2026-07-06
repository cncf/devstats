-- No max(event_id) watermarks: GitHub reset the event id sequence on 2025-10-08 (new ids are
-- LOWER than historical ones), so id watermarks silently skip all new rows. Instead: insert
-- rows with event time (dup_created_at) >= max(created_at) - 1 month; the PK + ON CONFLICT DO
-- NOTHING keeps re-runs free; empty (truncated) table => full rebuild.
-- Second statement: the tiny static sync-range (event_id >= 329900000000000), no time window.
-- Backfills older than the window: postprocess_labels_range.sql (GHA2DB_POSTPROCESS_FROM/TO).
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
