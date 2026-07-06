-- gha_sync_audit.sql - cheap, DB-only audit of GHA ingestion completeness for one project DB.
--
-- It answers, without downloading anything:
--   A. Did the sync fetch every hour?                  (gaps in gha_parsed)
--   B. Is the parsed watermark ahead of real content?  (hours marked processed but empty)
--   C. Which event types declined, and when?           (weekly real gha_events by type)
--   D. Is API enrichment covering raw events?           (PushEvent->commits, PullRequestEvent->PR rows)
--   E/F. Is gha_texts populated for /approve / comments? (the approves-cliff diagnostic)
--   G. gha_texts composition                            (real / artificial / sync buckets)
--
-- It does NOT prove GH Archive had more data than we imported - use util_py/verify_gha_archive_against_db.py
-- for that. Together: (A,B) clean + verifier "missing_in_db=0" => the decline is upstream, not a sync miss.
--
-- Usage (from a project DB, e.g. kubernetes -> gha):
--   PG_DB=gha psql gha -v from="'2025-07-01 00:00:00'" -v to="'2026-07-01 00:00:00'" -f util_sql/gha_sync_audit.sql
-- Note: :from must be an exact hour boundary for the gap check. Quote as shown so it becomes a SQL literal.

\set ON_ERROR_STOP on

\echo '== A. Count of missing (never-parsed) hours in gha_parsed within [from, to) - expect 0 =='
select count(*) as missing_hours
from generate_series(:from::timestamp, :to::timestamp - interval '1 hour', interval '1 hour') gs(h)
left join gha_parsed p on p.dt = gs.h
where p.dt is null;

\echo '== A2. First 200 missing hours (if any) =='
select gs.h as missing_hour
from generate_series(:from::timestamp, :to::timestamp - interval '1 hour', interval '1 hour') gs(h)
left join gha_parsed p on p.dt = gs.h
where p.dt is null
order by gs.h
limit 200;

\echo '== B. Parsed watermark vs newest real-event content (a large gap => hours marked done but empty) =='
select
  (select max(dt) from gha_parsed)                                          as max_parsed_hour,
  (select max(created_at) from gha_events where id < 281474976710657)       as max_real_event_created_at,
  (select max(created_at) from gha_events)                                  as max_any_event_created_at;

\echo '== C. Weekly REAL gha_events totals (id < 2^48) - the raw ingestion volume trend =='
select date_trunc('week', created_at) as week, count(*) as real_events
from gha_events
where created_at >= :from::timestamp and created_at < :to::timestamp
  and id < 281474976710657
group by 1 order by 1;

\echo '== C2. Weekly REAL gha_events by type - shows WHICH event types declined =='
select date_trunc('week', created_at) as week, type, count(*) as n
from gha_events
where created_at >= :from::timestamp and created_at < :to::timestamp
  and id < 281474976710657
  and type in (
    'PushEvent','PullRequestEvent','IssuesEvent','PullRequestReviewEvent',
    'PullRequestReviewCommentEvent','IssueCommentEvent','CommitCommentEvent'
  )
group by 1, 2 order by 1, 2;

\echo '== D. Enrichment coverage per week: PushEvent->gha_commits, PullRequestEvent->gha_pull_requests =='
select date_trunc('week', e.created_at) as week,
  count(*) filter (where e.type = 'PushEvent') as push_events,
  count(*) filter (where e.type = 'PushEvent'
    and exists (select 1 from gha_commits c where c.event_id = e.id)) as push_events_with_commit_rows,
  count(*) filter (where e.type = 'PullRequestEvent') as pr_events,
  count(*) filter (where e.type = 'PullRequestEvent'
    and exists (select 1 from gha_pull_requests pr where pr.event_id = e.id)) as pr_events_with_pr_rows
from gha_events e
where e.created_at >= :from::timestamp and e.created_at < :to::timestamp
  and e.id < 281474976710657
group by 1 order by 1;

\echo '== E. /approve comments vs /approve present in gha_texts, per week (texts should track comments) =='
select date_trunc('week', c.created_at) as week,
  count(*) as approve_comments,
  count(*) filter (
    where exists (select 1 from gha_texts t where t.event_id = c.event_id and t.body = c.body)
  ) as approve_comments_in_texts
from gha_comments c
where c.created_at >= :from::timestamp and c.created_at < :to::timestamp
  and substring(c.body from '(?i)(?:^|\n|\r)\s*/(?:approve)\s*(?:\n|\r|$)') is not null
group by 1 order by 1;

\echo '== F. Comments in range with a non-empty body but NO matching gha_texts row (generated-table hole) =='
select count(*) as comments_missing_texts
from gha_comments c
where c.created_at >= :from::timestamp and c.created_at < :to::timestamp
  and c.body <> ''
  and not exists (select 1 from gha_texts t where t.event_id = c.event_id and t.body = c.body);

\echo '== G. gha_texts composition by id-bucket (real / artificial / sync) =='
select
  case when event_id < 281474976710657 then '0-real'
       when event_id < 329900000000000 and type like '%Event' then '1-artificial-restored'
       when event_id < 329900000000000 then '1-artificial'
       else '2-sync' end as bucket,
  count(*) as rows, min(created_at) as min_dt, max(created_at) as max_dt
from gha_texts
group by 1 order by 1;
