create temp table issues_{{rnd}} as (
  select distinct
    id,
    user_id,
    created_at
  from
    gha_issues
  where
    is_pull_request = true
    and created_at >= '{{from}}'
    and created_at < '{{to}}'
    and (lower(dup_user_login) {{exclude_bots}})
);
create index on issues_{{rnd}}(id);
create index on issues_{{rnd}}(user_id);
create index on issues_{{rnd}}(created_at);
analyze issues_{{rnd}};

create temp table issues_next_{{rnd}} as (
  select
    c.id,
    c.created_at,
    n.dup_repo_id as repo_id,
    n.dup_repo_name as repo_name,
    min(n.updated_at) as updated_at
  from
    issues_{{rnd}} c,
    gha_issues n
  where
    n.id = c.id
    and n.is_pull_request = true
    and n.dup_actor_id != c.user_id
    and n.created_at >= '{{from}}'
    and n.created_at < '{{to}}'
    and n.updated_at > c.created_at + '30 seconds'::interval
    and n.dup_type like '%Event'
    and (lower(n.dup_actor_login) {{exclude_bots}})
  group by
    1, 2, 3, 4
);
create index on issues_next_{{rnd}}(repo_id);
create index on issues_next_{{rnd}}(repo_name);
analyze issues_next_{{rnd}};

create temp table prs_{{rnd}} as (
  select distinct
    id,
    user_id,
    created_at
  from
    gha_pull_requests
  where
    created_at >= '{{from}}'
    and created_at < '{{to}}'
    and (lower(dup_user_login) {{exclude_bots}})
);
create index on prs_{{rnd}}(id);
create index on prs_{{rnd}}(user_id);
create index on prs_{{rnd}}(created_at);
analyze prs_{{rnd}};

create temp table prs_next_{{rnd}} as (
  select
    c.id,
    c.created_at,
    n.dup_repo_id as repo_id,
    n.dup_repo_name as repo_name,
    min(n.updated_at) as updated_at
  from
    prs_{{rnd}} c,
    gha_pull_requests n
  where
    n.id = c.id
    and n.dup_actor_id != c.user_id
    and n.created_at >= '{{from}}'
    and n.created_at < '{{to}}'
    and n.updated_at > c.created_at + '30 seconds'::interval
    and n.dup_type like '%Event'
    and (lower(n.dup_actor_login) {{exclude_bots}})
  group by
    1, 2, 3, 4
);
create index on prs_next_{{rnd}}(repo_id);
create index on prs_next_{{rnd}}(repo_name);
analyze prs_next_{{rnd}};

create temp table tdiffs_{{rnd}} as (
  select
    i.id,
    extract(epoch from i.updated_at - i.created_at) / 3600 as diff,
    r.repo_group as repo_group
  from
    issues_next_{{rnd}} i,
    gha_repo_groups r
  where
    r.name = i.repo_name
    and r.id = i.repo_id
  union select
    p.id,
    extract(epoch from p.updated_at - p.created_at) / 3600 as diff,
    r.repo_group as repo_group
  from
    prs_next_{{rnd}} p,
    gha_repo_groups r
  where
    r.name = p.repo_name
    and r.id = p.repo_id
);
create index on tdiffs_{{rnd}}(repo_group);
analyze tdiffs_{{rnd}};

select
  'non_auth;All;p15,med,p85' as name,
  percentile_disc(0.15) within group (order by diff asc) as non_author_15_percentile,
  percentile_disc(0.5) within group (order by diff asc) as non_author_median,
  percentile_disc(0.85) within group (order by diff asc) as non_author_85_percentile
from
  tdiffs_{{rnd}}
where
  repo_group is not null
union select 'non_auth;' || repo_group || ';p15,med,p85' as name,
  percentile_disc(0.15) within group (order by diff asc) as non_author_15_percentile,
  percentile_disc(0.5) within group (order by diff asc) as non_author_median,
  percentile_disc(0.85) within group (order by diff asc) as non_author_85_percentile
from
  tdiffs_{{rnd}}
where
  repo_group is not null
group by
  repo_group
order by
  non_author_median desc,
  name asc
;
