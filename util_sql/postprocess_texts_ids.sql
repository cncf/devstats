-- Targeted, idempotent rebuild of gha_texts for an exact set of restored event ids (PHASE 2b).
--
-- Companion to postprocess_texts_range.sql. That script rebuilds by a [from, to) event-time window;
-- this one rebuilds ONLY the event ids listed in the pp_event_ids temp table. It is what ghapi2db /
-- get_repos run automatically after API restores: the restore code knows exactly which event ids it
-- inserted, so the cost is O(restored rows) - a single restored months-old comment no longer triggers
-- a months-wide window rebuild on the biggest tables (allprj gha_texts is 85 GB).
--
-- Requires: create temp table pp_event_ids(event_id bigint not null) + inserted ids + analyze, all in
-- the same transaction (RunEventIDsPostprocess in devstatscode does this). Delete-then-insert by
-- event_id, exactly like the range variant: gha_texts has no unique key and stores the source TEXT
-- timestamp in created_at, so only an event_id delete matches what is re-inserted. Idempotent.
-- For manual window backfills keep using GHA2DB_POSTPROCESS_FROM/_TO + the *_range.sql scripts.

delete from gha_texts t
using pp_event_ids c
where t.event_id = c.event_id
;

insert into gha_texts(
  event_id, body, created_at, repo_id, repo_name, actor_id, actor_login, type
)
select event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from gha_comments where body != '' and event_id in (select event_id from pp_event_ids)
union select event_id, message, dup_created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from gha_commits where message != '' and event_id in (select event_id from pp_event_ids)
union select event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from gha_issues where title != '' and event_id in (select event_id from pp_event_ids)
union select event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from gha_issues where body != '' and event_id in (select event_id from pp_event_ids)
union select event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from gha_pull_requests where title != '' and event_id in (select event_id from pp_event_ids)
union select event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from gha_pull_requests where body != '' and event_id in (select event_id from pp_event_ids)
union select event_id, body, submitted_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from gha_reviews where body != '' and event_id in (select event_id from pp_event_ids)
;
