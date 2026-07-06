-- No max(event_id) watermarks: GitHub reset the event id sequence on 2025-10-08 (new ids are
-- LOWER than historical ones), so id watermarks silently skip all new rows. Instead: insert
-- rows with event time (dup_created_at) >= max(created_at) - 1 month, deduped by anti-join on
-- row identity (event_id, body, created_at) so partial per-event rows heal; empty (truncated)
-- table => full rebuild; re-runs insert nothing and stay cheap.
-- Second statement: the tiny static sync-range (event_id >= 329900000000000), no time window.
-- Backfills older than the window: postprocess_texts_range.sql (GHA2DB_POSTPROCESS_FROM/TO).
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
    select 1 from gha_texts t where t.event_id = gha_comments.event_id and t.body = gha_comments.body and t.created_at = gha_comments.created_at
  )
union select
  event_id, message, dup_created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_commits, cutoff
where
  message != ''
  and dup_created_at >= cutoff.dt
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_commits.event_id and t.body = gha_commits.message and t.created_at = gha_commits.dup_created_at
  )
union select
  event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_issues, cutoff
where
  title != ''
  and dup_created_at >= cutoff.dt
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_issues.event_id and t.body = gha_issues.title and t.created_at = gha_issues.created_at
  )
union select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_issues, cutoff
where
  body != ''
  and dup_created_at >= cutoff.dt
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_issues.event_id and t.body = gha_issues.body and t.created_at = gha_issues.created_at
  )
union select
  event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_pull_requests, cutoff
where
  title != ''
  and dup_created_at >= cutoff.dt
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_pull_requests.event_id and t.body = gha_pull_requests.title and t.created_at = gha_pull_requests.created_at
  )
union select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_pull_requests, cutoff
where
  body != ''
  and dup_created_at >= cutoff.dt
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_pull_requests.event_id and t.body = gha_pull_requests.body and t.created_at = gha_pull_requests.created_at
  )
union select
  event_id, body, submitted_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_reviews, cutoff
where
  body != ''
  and dup_created_at >= cutoff.dt
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_reviews.event_id and t.body = gha_reviews.body and t.created_at = gha_reviews.submitted_at
  )
;

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
    select 1 from gha_texts t where t.event_id = gha_comments.event_id and t.body = gha_comments.body and t.created_at = gha_comments.created_at
  )
union select
  event_id, message, dup_created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_commits
where
  message != ''
  and event_id >= 329900000000000
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_commits.event_id and t.body = gha_commits.message and t.created_at = gha_commits.dup_created_at
  )
union select
  event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_issues
where
  title != ''
  and event_id >= 329900000000000
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_issues.event_id and t.body = gha_issues.title and t.created_at = gha_issues.created_at
  )
union select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_issues
where
  body != ''
  and event_id >= 329900000000000
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_issues.event_id and t.body = gha_issues.body and t.created_at = gha_issues.created_at
  )
union select
  event_id, title, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_pull_requests
where
  title != ''
  and event_id >= 329900000000000
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_pull_requests.event_id and t.body = gha_pull_requests.title and t.created_at = gha_pull_requests.created_at
  )
union select
  event_id, body, created_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_pull_requests
where
  body != ''
  and event_id >= 329900000000000
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_pull_requests.event_id and t.body = gha_pull_requests.body and t.created_at = gha_pull_requests.created_at
  )
union select
  event_id, body, submitted_at, dup_repo_id, dup_repo_name, dup_actor_id, dup_actor_login, dup_type
from
  gha_reviews
where
  body != ''
  and event_id >= 329900000000000
  and not exists (
    select 1 from gha_texts t where t.event_id = gha_reviews.event_id and t.body = gha_reviews.body and t.created_at = gha_reviews.submitted_at
  )
;
