-- No max(event_id) watermarks: GitHub reset the event id sequence on 2025-10-08 (new ids are
-- LOWER than historical ones), so id watermarks silently skip all new rows. Instead: insert
-- rows with event time (dup_created_at) >= max(created_at) - 1 month, deduped by anti-join on
-- row identity (event_id, body, created_at) so partial per-event rows heal; empty (truncated)
-- table => full rebuild; re-runs insert nothing and stay cheap.
-- Second statement: the tiny static sync-range (event_id >= 329900000000000), no time window.
-- Backfills older than the window: postprocess_texts_range.sql (GHA2DB_POSTPROCESS_FROM/TO);
-- automatic post-restore repairs use postprocess_texts_ids.sql (exact restored event id set).
-- Materialize matching texts once: large pushes can have hundreds of thousands of
-- bodies under one event_id, making per-source-row event-index probes quadratic.
with cutoff as (
  select coalesce(max(created_at), '1900-01-01'::timestamp) - interval '1 month' as dt
  from
    gha_texts
), candidates(event_id, body, created_at, repo_id, repo_name, actor_id, actor_login, type) as materialized (
select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_comments, cutoff
where
  body != ''
  and dup_created_at >= cutoff.dt
union select
  event_id, message, dup_created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_commits, cutoff
where
  message != ''
  and dup_created_at >= cutoff.dt
union select
  event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_issues, cutoff
where
  title != ''
  and dup_created_at >= cutoff.dt
union select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_issues, cutoff
where
  body != ''
  and dup_created_at >= cutoff.dt
union select
  event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_pull_requests, cutoff
where
  title != ''
  and dup_created_at >= cutoff.dt
union select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_pull_requests, cutoff
where
  body != ''
  and dup_created_at >= cutoff.dt
union select
  event_id, body, submitted_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_reviews, cutoff
where
  body != ''
  and dup_created_at >= cutoff.dt
), existing as materialized (
  select t.event_id, t.body, t.created_at
  from gha_texts t
  where t.event_id in (select event_id from candidates)
)
insert into gha_texts(
  event_id, body, created_at, repo_id, repo_name, actor_id, actor_login, type
)
select c.event_id, c.body, c.created_at, c.repo_id, c.repo_name, c.actor_id, c.actor_login, c.type
from candidates c
where not exists (
  select 1 from existing t
  where t.event_id = c.event_id and t.body = c.body and t.created_at = c.created_at
)
;

with candidates(event_id, body, created_at, repo_id, repo_name, actor_id, actor_login, type) as materialized (
select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_comments
where
  body != ''
  and event_id >= 329900000000000
union select
  event_id, message, dup_created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_commits
where
  message != ''
  and event_id >= 329900000000000
union select
  event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_issues
where
  title != ''
  and event_id >= 329900000000000
union select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_issues
where
  body != ''
  and event_id >= 329900000000000
union select
  event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_pull_requests
where
  title != ''
  and event_id >= 329900000000000
union select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_pull_requests
where
  body != ''
  and event_id >= 329900000000000
union select
  event_id, body, submitted_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_reviews
where
  body != ''
  and event_id >= 329900000000000
), existing as materialized (
  select t.event_id, t.body, t.created_at
  from gha_texts t
  where t.event_id in (select event_id from candidates)
)
insert into gha_texts(
  event_id, body, created_at, repo_id, repo_name, actor_id, actor_login, type
)
select c.event_id, c.body, c.created_at, c.repo_id, c.repo_name, c.actor_id, c.actor_login, c.type
from candidates c
where not exists (
  select 1 from existing t
  where t.event_id = c.event_id and t.body = c.body and t.created_at = c.created_at
)
;
