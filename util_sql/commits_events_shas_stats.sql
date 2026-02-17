select count(*), count(distinct sha), count(distinct event_id) from gha_commits;
select sha, count(distinct event_id) as cnt from gha_commits group by 1 order by 2 desc limit 10;
select event_id, count(distinct sha) as cnt from gha_commits group by 1 order by 2 desc limit 10;
