-- Targeted rebuild of gha_issues_events_labels for an exact set of restored event ids (PHASE 2b).
--
-- Companion to postprocess_labels_range.sql (window variant); driven by the pp_event_ids temp table
-- (see postprocess_texts_ids.sql for the contract). gha_issues_labels carries event_id, so both the
-- delete and the re-insert can key on it directly. Restores of comments/reviews/commits never insert
-- gha_issues_labels rows, so for the automatic post-restore run this is a cheap no-op; it only does
-- work if a caller ever passes event ids of label-carrying issue events. Idempotent.

delete from gha_issues_events_labels gel
using pp_event_ids c
where gel.event_id = c.event_id
;

insert into gha_issues_events_labels(
  issue_id, event_id, label_id, label_name, created_at,
  repo_id, repo_name, actor_id, actor_login, type
)
select
  il.issue_id, il.event_id, lb.id, lb.name, il.dup_created_at,
  il.dup_repo_id, il.dup_repo_name, il.dup_actor_id, il.dup_actor_login, il.dup_type
from
  gha_issues_labels il,
  gha_labels lb
where
  il.label_id = lb.id
  and il.event_id in (select event_id from pp_event_ids)
on conflict do nothing
;
