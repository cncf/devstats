-- Wipes ALL orphan-restored data from a DB, for a clean rerun with a fixed binary.
begin;

create temporary table tmp_orphan_events(event_id bigint primary key) on commit drop;

insert into tmp_orphan_events
select distinct event_id
from gha_commits
where origin = 2
on conflict do nothing;

insert into tmp_orphan_events
select distinct event_id
from gha_payloads
where action = 'restored_orphan_commit'
on conflict do nothing;

select count(*) as events_to_delete from tmp_orphan_events;

delete from gha_texts t
using tmp_orphan_events e
where t.event_id = e.event_id;

delete from gha_commits_roles r
using tmp_orphan_events e
where r.event_id = e.event_id;

delete from gha_payloads p
using tmp_orphan_events e
where p.event_id = e.event_id;

delete from gha_commits c
using tmp_orphan_events e
where c.event_id = e.event_id
  and c.origin = 2;

delete from gha_events ge
using tmp_orphan_events e
where ge.id = e.event_id
  and ge.id < 0
  and ge.type = 'PushEvent';

analyze gha_events;
analyze gha_payloads;
analyze gha_commits;
analyze gha_commits_roles;
analyze gha_texts;

commit;
