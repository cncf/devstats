-- Optimized "bus factor" (hbus) metric
-- Drop-in replacement: same output schema/logic, but uses {{rnd}} temp tables + indexes + analyze,
-- and avoids re-scanning huge base tables many times.

-- -------------------------
-- 1) Repo groups lookup
-- -------------------------
create temp table hbus_repo_groups_{{rnd}} as
select
  id,
  name,
  repo_group
from
  gha_repo_groups
;
create unique index on hbus_repo_groups_{{rnd}}(id, name);
create index on hbus_repo_groups_{{rnd}}(repo_group);
analyze hbus_repo_groups_{{rnd}};


-- -------------------------
-- 2) Commits: expand roles once, then attach affiliation once
--    (replaces 3 scans of gha_commits + 1 scan of gha_commits_roles with 1+1)
-- -------------------------
create temp table hbus_commits_roles_{{rnd}} as
select
  rg.repo_group,
  c.sha,
  c.dup_created_at as created_at,
  v.actor_id,
  lower(v.actor_login) as actor_login
from
  gha_commits c
join
  hbus_repo_groups_{{rnd}} rg
on
  rg.id = c.dup_repo_id
  and rg.name = c.dup_repo_name
cross join lateral (
  values
    ('actor',     c.dup_actor_id,   c.dup_actor_login),
    ('author',    c.author_id,      c.dup_author_login),
    ('committer', c.committer_id,   c.dup_committer_login)
) as v(role, actor_id, actor_login)
where
  {{period:c.dup_created_at}}
  and (lower(v.actor_login) {{exclude_bots}})
  and (
    v.role = 'actor'
    or v.actor_id is not null
  )

union all

select
  rg.repo_group,
  cr.sha,
  cr.dup_created_at as created_at,
  cr.actor_id,
  lower(cr.actor_login) as actor_login
from
  gha_commits_roles cr
join
  hbus_repo_groups_{{rnd}} rg
on
  rg.id = cr.dup_repo_id
  and rg.name = cr.dup_repo_name
where
  cr.actor_id is not null
  and cr.actor_id != 0
  and cr.role = 'Co-authored-by'
  and {{period:cr.dup_created_at}}
  and (lower(cr.actor_login) {{exclude_bots}})
;

create index on hbus_commits_roles_{{rnd}}(repo_group);
create index on hbus_commits_roles_{{rnd}}(sha);
create index on hbus_commits_roles_{{rnd}}(actor_login);
create index on hbus_commits_roles_{{rnd}}(actor_id, created_at);
analyze hbus_commits_roles_{{rnd}};

create temp table hbus_commits_data_{{rnd}} as
select distinct
  cr.repo_group,
  cr.sha,
  cr.actor_login,
  coalesce(aa.company_name, '') as company
from
  hbus_commits_roles_{{rnd}} cr
left join
  gha_actors_affiliations aa
on
  aa.actor_id = cr.actor_id
  and aa.dt_from <= cr.created_at
  and aa.dt_to > cr.created_at
;

create index on hbus_commits_data_{{rnd}}(repo_group, company);
create index on hbus_commits_data_{{rnd}}(repo_group, actor_login);
create index on hbus_commits_data_{{rnd}}(sha);
analyze hbus_commits_data_{{rnd}};


-- -------------------------
-- 3) Events: filter once to period/repos/bots, then attach org affiliation once
-- -------------------------
create temp table hbus_events_base_{{rnd}} as
select
  rg.repo_group,
  e.id,
  e.repo_id,
  e.type,
  e.created_at,
  e.actor_id,
  lower(e.dup_actor_login) as actor_login
from
  gha_events e
join
  hbus_repo_groups_{{rnd}} rg
on
  rg.id = e.repo_id
  and rg.name = e.dup_repo_name
where
  {{period:e.created_at}}
  and (lower(e.dup_actor_login) {{exclude_bots}})
;

-- key for affiliation join + grouping keys
create index on hbus_events_base_{{rnd}}(actor_id, created_at);
create index on hbus_events_base_{{rnd}}(repo_group, actor_login);
analyze hbus_events_base_{{rnd}};

create temp table hbus_events_org_{{rnd}} as
select
  e.repo_group,
  e.id,
  e.repo_id,
  e.type,
  aa.company_name as company
from
  hbus_events_base_{{rnd}} e
join
  gha_actors_affiliations aa
on
  aa.actor_id = e.actor_id
  and aa.dt_from <= e.created_at
  and aa.dt_to > e.created_at
where
  aa.company_name not in ('', 'Independent', '(Robots)')
;

create index on hbus_events_org_{{rnd}}(repo_group, company);
analyze hbus_events_org_{{rnd}};


-- -------------------------
-- 4) Comments: filter once, then attach org affiliation once
-- -------------------------
create temp table hbus_comments_base_{{rnd}} as
select
  rg.repo_group,
  c.id,
  c.created_at,
  c.user_id as actor_id,
  lower(c.dup_user_login) as actor_login
from
  gha_comments c
join
  hbus_repo_groups_{{rnd}} rg
on
  rg.id = c.dup_repo_id
  and rg.name = c.dup_repo_name
where
  {{period:c.created_at}}
  and (lower(c.dup_user_login) {{exclude_bots}})
;

create index on hbus_comments_base_{{rnd}}(actor_id, created_at);
create index on hbus_comments_base_{{rnd}}(repo_group, actor_login);
analyze hbus_comments_base_{{rnd}};

create temp table hbus_comments_org_{{rnd}} as
select
  c.repo_group,
  c.id,
  aa.company_name as company
from
  hbus_comments_base_{{rnd}} c
join
  gha_actors_affiliations aa
on
  aa.actor_id = c.actor_id
  and aa.dt_from <= c.created_at
  and aa.dt_to > c.created_at
where
  aa.company_name not in ('', 'Independent', '(Robots)')
;

create index on hbus_comments_org_{{rnd}}(repo_group, company);
analyze hbus_comments_org_{{rnd}};


-- -------------------------
-- 5) Issues (incl PRs): filter once, then attach org affiliation once
-- -------------------------
create temp table hbus_issues_base_{{rnd}} as
select
  rg.repo_group,
  i.id,
  i.created_at,
  i.user_id as actor_id,
  lower(i.dup_user_login) as actor_login,
  i.is_pull_request
from
  gha_issues i
join
  hbus_repo_groups_{{rnd}} rg
on
  rg.id = i.dup_repo_id
  and rg.name = i.dup_repo_name
where
  {{period:i.created_at}}
  and (lower(i.dup_user_login) {{exclude_bots}})
;

create index on hbus_issues_base_{{rnd}}(actor_id, created_at);
create index on hbus_issues_base_{{rnd}}(repo_group, actor_login);
create index on hbus_issues_base_{{rnd}}(is_pull_request);
analyze hbus_issues_base_{{rnd}};

create temp table hbus_issues_org_{{rnd}} as
select
  i.repo_group,
  i.id,
  i.is_pull_request,
  aa.company_name as company
from
  hbus_issues_base_{{rnd}} i
join
  gha_actors_affiliations aa
on
  aa.actor_id = i.actor_id
  and aa.dt_from <= i.created_at
  and aa.dt_to > i.created_at
where
  aa.company_name not in ('', 'Independent', '(Robots)')
;

create index on hbus_issues_org_{{rnd}}(repo_group, company);
create index on hbus_issues_org_{{rnd}}(is_pull_request);
analyze hbus_issues_org_{{rnd}};


-- -------------------------
-- 6) Merged PRs: filter once, then attach org affiliation once
-- -------------------------
create temp table hbus_merged_prs_base_{{rnd}} as
select
  rg.repo_group,
  pr.id,
  pr.merged_at,
  pr.user_id as actor_id,
  lower(pr.dup_user_login) as actor_login
from
  gha_pull_requests pr
join
  hbus_repo_groups_{{rnd}} rg
on
  rg.id = pr.dup_repo_id
  and rg.name = pr.dup_repo_name
where
  pr.merged_at is not null
  and {{period:pr.merged_at}}
  and (lower(pr.dup_user_login) {{exclude_bots}})
;

create index on hbus_merged_prs_base_{{rnd}}(actor_id, merged_at);
create index on hbus_merged_prs_base_{{rnd}}(repo_group, actor_login);
analyze hbus_merged_prs_base_{{rnd}};

create temp table hbus_merged_prs_org_{{rnd}} as
select
  pr.repo_group,
  pr.id,
  aa.company_name as company
from
  hbus_merged_prs_base_{{rnd}} pr
join
  gha_actors_affiliations aa
on
  aa.actor_id = pr.actor_id
  and aa.dt_from <= pr.merged_at
  and aa.dt_to > pr.merged_at
where
  aa.company_name not in ('', 'Independent', '(Robots)')
;

create index on hbus_merged_prs_org_{{rnd}}(repo_group, company);
analyze hbus_merged_prs_org_{{rnd}};


-- -------------------------
-- 7) Build a single long-format (repo_group,metric,tp,name,cnt) table
--    NOTE: For events & issues we compute multiple metrics in one aggregation pass
--          and then "unpivot" via LATERAL VALUES while filtering cnt>0 to preserve original logic.
-- -------------------------
create temp table hbus_counts_{{rnd}} (
  repo_group text,
  metric text,
  tp text,
  name text,
  cnt double precision
);

-- commits (org)
insert into hbus_counts_{{rnd}}
select
  case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
  'commits' as metric,
  'org' as tp,
  company as name,
  round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) as cnt
from
  hbus_commits_data_{{rnd}}
where
  company not in ('', 'Independent', '(Robots)')
group by
  grouping sets ((repo_group, company), (company));

-- commits (usr)
insert into hbus_counts_{{rnd}}
select
  case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
  'commits' as metric,
  'usr' as tp,
  actor_login as name,
  round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) as cnt
from
  hbus_commits_data_{{rnd}}
group by
  grouping sets ((repo_group, actor_login), (actor_login));

-- events-derived metrics (usr) in one pass
with ev as (
  select
    case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
    actor_login,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (
      where type in (
        'IssuesEvent', 'PullRequestEvent', 'PushEvent',
        'PullRequestReviewCommentEvent', 'IssueCommentEvent',
        'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
      )
    ))) as contributions,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'PushEvent'))) as pushes,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'PullRequestReviewCommentEvent'))) as review_comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'PullRequestReviewEvent'))) as reviews,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'IssueCommentEvent'))) as issue_comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'CommitCommentEvent'))) as commit_comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(repo_id)))) as active_repos,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as events
  from
    hbus_events_base_{{rnd}}
  group by
    grouping sets ((repo_group, actor_login), (actor_login))
)
insert into hbus_counts_{{rnd}}
select
  repo_group,
  m.metric,
  'usr' as tp,
  actor_login as name,
  m.cnt
from
  ev
cross join lateral (values
  ('contributions',  contributions),
  ('pushes',         pushes),
  ('review_comments',review_comments),
  ('reviews',        reviews),
  ('issue_comments', issue_comments),
  ('commit_comments',commit_comments),
  ('active_repos',   active_repos),
  ('events',         events)
) as m(metric, cnt)
where
  m.cnt > 0;

-- events-derived metrics (org) in one pass
with ev as (
  select
    case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
    company,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (
      where type in (
        'IssuesEvent', 'PullRequestEvent', 'PushEvent',
        'PullRequestReviewCommentEvent', 'IssueCommentEvent',
        'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
      )
    ))) as contributions,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'PushEvent'))) as pushes,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'PullRequestReviewCommentEvent'))) as review_comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'PullRequestReviewEvent'))) as reviews,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'IssueCommentEvent'))) as issue_comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'CommitCommentEvent'))) as commit_comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(repo_id)))) as active_repos,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as events
  from
    hbus_events_org_{{rnd}}
  group by
    grouping sets ((repo_group, company), (company))
)
insert into hbus_counts_{{rnd}}
select
  repo_group,
  m.metric,
  'org' as tp,
  company as name,
  m.cnt
from
  ev
cross join lateral (values
  ('contributions',  contributions),
  ('pushes',         pushes),
  ('review_comments',review_comments),
  ('reviews',        reviews),
  ('issue_comments', issue_comments),
  ('commit_comments',commit_comments),
  ('active_repos',   active_repos),
  ('events',         events)
) as m(metric, cnt)
where
  m.cnt > 0;

-- comments (usr)
insert into hbus_counts_{{rnd}}
select
  case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
  'comments' as metric,
  'usr' as tp,
  actor_login as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as cnt
from
  hbus_comments_base_{{rnd}}
group by
  grouping sets ((repo_group, actor_login), (actor_login));

-- comments (org)
insert into hbus_counts_{{rnd}}
select
  case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
  'comments' as metric,
  'org' as tp,
  company as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as cnt
from
  hbus_comments_org_{{rnd}}
group by
  grouping sets ((repo_group, company), (company));

-- issues + prs (usr) in one pass
with ia as (
  select
    case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
    actor_login,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where is_pull_request = false))) as issues,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where is_pull_request = true))) as prs
  from
    hbus_issues_base_{{rnd}}
  group by
    grouping sets ((repo_group, actor_login), (actor_login))
)
insert into hbus_counts_{{rnd}}
select
  repo_group,
  m.metric,
  'usr' as tp,
  actor_login as name,
  m.cnt
from
  ia
cross join lateral (values
  ('issues', issues),
  ('prs',    prs)
) as m(metric, cnt)
where
  m.cnt > 0;

-- issues + prs (org) in one pass
with ia as (
  select
    case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
    company,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where is_pull_request = false))) as issues,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where is_pull_request = true))) as prs
  from
    hbus_issues_org_{{rnd}}
  group by
    grouping sets ((repo_group, company), (company))
)
insert into hbus_counts_{{rnd}}
select
  repo_group,
  m.metric,
  'org' as tp,
  company as name,
  m.cnt
from
  ia
cross join lateral (values
  ('issues', issues),
  ('prs',    prs)
) as m(metric, cnt)
where
  m.cnt > 0;

-- merged_prs (usr)
insert into hbus_counts_{{rnd}}
select
  case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
  'merged_prs' as metric,
  'usr' as tp,
  actor_login as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as cnt
from
  hbus_merged_prs_base_{{rnd}}
group by
  grouping sets ((repo_group, actor_login), (actor_login));

-- merged_prs (org)
insert into hbus_counts_{{rnd}}
select
  case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
  'merged_prs' as metric,
  'org' as tp,
  company as name,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as cnt
from
  hbus_merged_prs_org_{{rnd}}
group by
  grouping sets ((repo_group, company), (company));

create index on hbus_counts_{{rnd}}(repo_group, metric, tp);
analyze hbus_counts_{{rnd}};


-- -------------------------
-- 8) Rank + cumulative + bus factor + top 10 (same logic as your original)
-- -------------------------
create temp table hbus_rg_{{rnd}} as
select
  row_number() over (
    partition by repo_group, metric, tp
    order by cnt desc
  ) as row_number,
  repo_group,
  metric,
  tp,
  name,
  cnt
from
  hbus_counts_{{rnd}}
where
  cnt is not null
  and cnt > 0
;

create index on hbus_rg_{{rnd}}(repo_group, metric, tp, row_number);
analyze hbus_rg_{{rnd}};

create temp table hbus_all_rg_{{rnd}} as
select
  repo_group,
  metric,
  tp,
  sum(cnt) as cnt
from
  hbus_rg_{{rnd}}
group by
  repo_group,
  metric,
  tp
;

create index on hbus_all_rg_{{rnd}}(repo_group, metric, tp);
analyze hbus_all_rg_{{rnd}};

create temp table hbus_cum_rg_{{rnd}} as
select
  r.repo_group,
  r.metric,
  r.tp,
  r.row_number,
  r.cnt,
  r.name,
  100.0 * r.cnt / (case ar.cnt when 0 then 1 else ar.cnt end) as percent,
  (100.0 * sum(r.cnt) over (
    partition by r.repo_group, r.metric, r.tp
    order by r.row_number asc
    rows between unbounded preceding and current row
  )) / (case r.cnt when 0 then 1 else ar.cnt end) as cumulative_percent
from
  hbus_rg_{{rnd}} r
join
  hbus_all_rg_{{rnd}} ar
on
  r.repo_group = ar.repo_group
  and r.metric = ar.metric
  and r.tp = ar.tp
order by
  r.repo_group, r.metric, r.tp, r.row_number
;

create index on hbus_cum_rg_{{rnd}}(repo_group, metric, tp, row_number);
analyze hbus_cum_rg_{{rnd}};

create temp table hbus_bf_{{rnd}} as
select
  repo_group,
  metric,
  tp,
  min(row_number) as bus_factor,
  min(cumulative_percent) as percent,
  max(row_number) - min(row_number) as others_count,
  100.0 - min(cumulative_percent) as others_percent
from
  hbus_cum_rg_{{rnd}}
where
  cumulative_percent > 50.0
group by
  repo_group,
  metric,
  tp
;

create index on hbus_bf_{{rnd}}(repo_group, metric, tp);
analyze hbus_bf_{{rnd}};

create temp table hbus_bfa_{{rnd}} as
select
  b.repo_group,
  b.metric,
  b.tp,
  b.bus_factor,
  b.percent,
  (
    select string_agg(cr.name, ', ' order by cr.row_number)
    from hbus_cum_rg_{{rnd}} cr
    where
      cr.repo_group = b.repo_group
      and cr.metric = b.metric
      and cr.tp = b.tp
      and cr.row_number <= b.bus_factor
      and cr.row_number <= 10
  ) as companies,
  b.others_count,
  b.others_percent
from
  hbus_bf_{{rnd}} b
;

create index on hbus_bfa_{{rnd}}(repo_group, metric, tp);
analyze hbus_bfa_{{rnd}};

create temp table hbus_topa_{{rnd}} as
select
  t.repo_group,
  t.metric,
  t.tp,
  t.top_n,
  t.top_percent,
  (
    select string_agg(cr.name, ', ' order by cr.row_number)
    from hbus_cum_rg_{{rnd}} cr
    where
      cr.repo_group = t.repo_group
      and cr.metric = t.metric
      and cr.tp = t.tp
      and cr.row_number <= t.top_n
  ) as companies,
  t.non_top_percent
from (
  select
    repo_group,
    metric,
    tp,
    max(row_number) as top_n,
    max(cumulative_percent) as top_percent,
    100.0 - max(cumulative_percent) as non_top_percent
  from
    hbus_cum_rg_{{rnd}}
  where
    row_number <= 10
  group by
    repo_group,
    metric,
    tp
) t
;

create index on hbus_topa_{{rnd}}(repo_group, metric, tp);
analyze hbus_topa_{{rnd}};


-- -------------------------
-- 9) Final output (same shape as original)
-- -------------------------
select
  'hbus,' || b.tp || '_' || b.metric as type_metric,
  b.repo_group || '$$' ||
  b.percent || '$$' ||
  b.companies || '$$' ||
  b.others_count || '$$' ||
  b.others_percent || '$$' ||
  t.top_n || '$$' ||
  t.top_percent || '$$' ||
  t.companies || '$$' ||
  ((b.bus_factor + b.others_count) - t.top_n) || '$$' ||
  t.non_top_percent as name,
  b.bus_factor as value
from
  hbus_bfa_{{rnd}} b
join
  hbus_topa_{{rnd}} t
on
  b.repo_group = t.repo_group
  and b.metric = t.metric
  and b.tp = t.tp
;

