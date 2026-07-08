-- Removes orphan-restored (origin=2) commits whose sha already exists as non-orphan,
-- plus duplicate origin=2 rows per sha (keeps one). Unique fork/upstream rows stay.
begin;

create temporary table tmp_bad_orphan_events on commit drop as
with origin2 as (
  select
    c.sha,
    c.event_id,
    row_number() over (
      partition by c.sha
      order by c.inserted_at nulls last, c.event_id
    ) as rn
  from gha_commits c
  where c.origin = 2
),
bad_because_real_exists as (
  select distinct o.event_id
  from origin2 o
  where exists (
    select 1
    from gha_commits c
    where c.sha = o.sha
      and c.origin <> 2
  )
),
bad_duplicate_origin2 as (
  select o.event_id
  from origin2 o
  where o.rn > 1
    and not exists (
      select 1
      from gha_commits c
      where c.sha = o.sha
        and c.origin <> 2
    )
)
select distinct event_id
from bad_because_real_exists
union
select distinct event_id
from bad_duplicate_origin2
;

select count(*) as events_to_delete from tmp_bad_orphan_events;

delete from gha_texts t
using tmp_bad_orphan_events e
where t.event_id = e.event_id;

delete from gha_commits_roles r
using tmp_bad_orphan_events e
where r.event_id = e.event_id;

delete from gha_payloads p
using tmp_bad_orphan_events e
where p.event_id = e.event_id;

delete from gha_commits c
using tmp_bad_orphan_events e
where c.event_id = e.event_id
  and c.origin = 2;

delete from gha_events ge
using tmp_bad_orphan_events e
where ge.id = e.event_id
  and ge.id < 0
  and ge.type = 'PushEvent';

analyze gha_events;
analyze gha_payloads;
analyze gha_commits;
analyze gha_commits_roles;
analyze gha_texts;

commit;
