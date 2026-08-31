create temp table dch_commits_{{rnd}} as
select
  c.sha,
  c.author_id,
  c.dup_created_at,
  lower(c.dup_author_login) as author_lower
from
  gha_events_commits_files ecf,
  gha_commits c
where
  c.sha = ecf.sha
  and (ecf.path like '%.md' or ecf.path like '%.MD')
  and {{period:c.dup_created_at}}
;
-- filter bots once per distinct login instead of once per scanned row,
-- the temp table barrier keeps the ~100 like patterns off the base scans
create temp table dch_logins_{{rnd}} as
select distinct author_lower as login from dch_commits_{{rnd}}
;
delete from dch_commits_{{rnd}}
where
  author_lower is null
  or author_lower in (
    select login from dch_logins_{{rnd}} where not (login {{exclude_bots}})
  )
;
analyze dch_commits_{{rnd}};

create temp table dch_company_{{rnd}} as
select
  affs.company_name as company,
  c.sha,
  c.author_id
from
  dch_commits_{{rnd}} c
left join
  gha_actors_affiliations affs
on
  c.author_id = affs.actor_id
  and affs.dt_from <= c.dup_created_at
  and affs.dt_to > c.dup_created_at
  and affs.company_name != ''
;
analyze dch_company_{{rnd}};

select 
  'hcom,' || sub.metric as metric,
  sub.company as name,
  sub.value as value
from (
  select 'Documentation commits' as metric,
    company,
    count(distinct sha) as value
  from
    dch_company_{{rnd}}
  group by
    company
  union all select 'Documentation committers' as metric,
    company,
    count(distinct author_id) as value
  from
    dch_company_{{rnd}}
  group by
    company
  union all select 'Documentation commits' as metric,
    'All' as company,
    count(distinct sha) as value
  from
    dch_commits_{{rnd}}
  union all select 'Documentation committers' as metric,
    'All' as company,
    count(distinct author_id) as value
  from
    dch_commits_{{rnd}}
  ) sub
where
  sub.company is not null
order by
  metric asc,
  value desc,
  name asc
;
drop table dch_company_{{rnd}};
drop table dch_commits_{{rnd}};
drop table dch_logins_{{rnd}};
