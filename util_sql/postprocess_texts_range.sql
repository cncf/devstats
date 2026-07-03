-- Bounded, idempotent rebuild of gha_texts for a backfill window [from, to)  (PHASE 2).
--
-- Companion to postprocess_texts.sql (the unchanged hourly max(event_id) script). Run THIS after a
-- historical backfill so gha_texts reflects rows that arrive after newer rows already exist (the hourly
-- watermark would skip them). The simplest correct alternative is a full "truncate gha_texts + run
-- structure" rebuild (see runbook) - use that unless the table is too large to fully rebuild.
--
-- KEY: we rebuild by the SOURCE event-time, not by gha_texts.created_at. All event-derived branches -
-- comments/commits/issues/pull_requests/reviews - select the changed event set by dup_created_at (the
-- event/backfill time), because gha_texts.created_at stores the source TEXT timestamp (comment.created_at,
-- issue/pr.created_at, commit.dup_created_at, review.submitted_at), which can predate the backfill window
-- (e.g. a PR created before the window but backfilled via ghapi2db inside it). So we collect the event_ids
-- whose dup_created_at is in the window, delete all gha_texts rows for those event_ids, and re-insert all
-- text rows for them (the inserted created_at still preserves each source text timestamp). gha_texts has no
-- unique key -> delete-then-insert by event_id; re-running the same window is idempotent.
--
-- SCOPE: this is a "repair the missing/changed CURRENT source rows" mode. It cannot purge an orphan gha_texts
-- row whose artificial source row (issue/PR) was already DELETED (that event_id no longer appears in any
-- source, so it is neither deleted nor re-created here). For a guaranteed-clean rebuild use the runbook's
-- primary path: truncate gha_texts + normal structure.
--
-- The window is read from session settings devstats.postprocess_from / devstats.postprocess_to. Those are
-- set by `structure` (from GHA2DB_POSTPROCESS_FROM / GHA2DB_POSTPROCESS_TO), or manually in psql:
--     set devstats.postprocess_from = '2025-10-08 00:00:00';
--     set devstats.postprocess_to   = '2026-04-22 00:00:00';   -- exclusive upper bound
--     \i util_sql/postprocess_texts_range.sql
-- Unset/empty settings => NULL bounds => this is a safe no-op.

with pp as (
  select
    nullif(current_setting('devstats.postprocess_from', true), '')::timestamp as pfrom,
    nullif(current_setting('devstats.postprocess_to', true), '')::timestamp as pto
), changed as (
  select event_id from gha_comments,      pp where dup_created_at >= pp.pfrom and dup_created_at < pp.pto
  union select event_id from gha_commits,       pp where dup_created_at >= pp.pfrom and dup_created_at < pp.pto
  union select event_id from gha_issues,        pp where dup_created_at >= pp.pfrom and dup_created_at < pp.pto
  union select event_id from gha_pull_requests, pp where dup_created_at >= pp.pfrom and dup_created_at < pp.pto
  union select event_id from gha_reviews,       pp where dup_created_at >= pp.pfrom and dup_created_at < pp.pto
)
delete from gha_texts t using changed c where t.event_id = c.event_id
;

with pp as (
  select
    nullif(current_setting('devstats.postprocess_from', true), '')::timestamp as pfrom,
    nullif(current_setting('devstats.postprocess_to', true), '')::timestamp as pto
), changed as (
  select event_id from gha_comments,      pp where dup_created_at >= pp.pfrom and dup_created_at < pp.pto
  union select event_id from gha_commits,       pp where dup_created_at >= pp.pfrom and dup_created_at < pp.pto
  union select event_id from gha_issues,        pp where dup_created_at >= pp.pfrom and dup_created_at < pp.pto
  union select event_id from gha_pull_requests, pp where dup_created_at >= pp.pfrom and dup_created_at < pp.pto
  union select event_id from gha_reviews,       pp where dup_created_at >= pp.pfrom and dup_created_at < pp.pto
)
insert into gha_texts(
  event_id, body, created_at, repo_id, repo_name, actor_id, actor_login, type
)
select event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from gha_comments where body != '' and event_id in (select event_id from changed)
union select event_id, message, dup_created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from gha_commits where message != '' and event_id in (select event_id from changed)
union select event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from gha_issues where title != '' and event_id in (select event_id from changed)
union select event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from gha_issues where body != '' and event_id in (select event_id from changed)
union select event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from gha_pull_requests where title != '' and event_id in (select event_id from changed)
union select event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from gha_pull_requests where body != '' and event_id in (select event_id from changed)
union select event_id, body, submitted_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from gha_reviews where body != '' and event_id in (select event_id from changed)
;
