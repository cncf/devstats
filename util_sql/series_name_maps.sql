select distinct
  r.repo_group,
  s.period
from gha_repos r
join sannotations_shared s
  on s.repo = r.name
where nullif(btrim(r.repo_group), '') is not null
  and nullif(btrim(s.period), '') is not null
order by
  r.repo_group,
  s.period;

select distinct
  s.period,
  r.repo_group
from gha_repos r
join sannotations_shared s
  on s.repo = r.name
where nullif(btrim(r.repo_group), '') is not null
  and nullif(btrim(s.period), '') is not null
order by
  s.period,
  r.repo_group;

with pairs as (
  select distinct
    r.repo_group,
    s.period
  from gha_repos r
  join sannotations_shared s
    on s.repo = r.name
  where nullif(btrim(r.repo_group), '') is not null
    and nullif(btrim(s.period), '') is not null
)
select
  repo_group,
  count(*) as periods_cnt,
  array_agg(period order by period) as periods
from pairs
group by repo_group
order by repo_group;
