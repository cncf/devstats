select count(*) as count, count(distinct sha) as dist_shas, count(distinct event_id) as dist_events from gha_commits;
select origin, count(distinct sha) as dist_shas, count(distinct event_id) as dist_events, count(*) as count from gha_commits group by 1;
select sha, count(distinct event_id) as dist_events from gha_commits group by 1 order by 2 desc limit 10;
select event_id, count(distinct sha) as dist_shas from gha_commits group by 1 order by 2 desc limit 10;
