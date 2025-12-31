-- ============================================================
-- Optimized + equivalent replacement for metrics/shared/bus_factor.sql
-- Uses {{rnd}} temp tables + indexes + analyze, safe for parallel runs.
-- ============================================================

-- -------------------------
-- 0) Repo groups mapping (keep (id,name) multiplicity!)
-- -------------------------
create temp table hbus_repo_groups_{{rnd}} as
select id, name, repo_group
from gha_repo_groups;

create index on hbus_repo_groups_{{rnd}}(id, name);
create index on hbus_repo_groups_{{rnd}}(repo_group);
analyze hbus_repo_groups_{{rnd}};

-- -------------------------
-- 1) Commits roles expanded once (actor/author/committer + co-authored-by)
--    NOTE: commit actor_login is LOWER() exactly like original.
--    Precompute sha_h once to avoid repeated hll_hash_text calls.
-- -------------------------
create temp table hbus_commits_roles_{{rnd}} as
select
  rg.repo_group,
  c.dup_created_at as created_at,
  v.actor_id,
  lower(v.actor_login) as actor_login,
  hll_hash_text(c.sha) as sha_h
from gha_commits c
join hbus_repo_groups_{{rnd}} rg
  on rg.id = c.dup_repo_id and rg.name = c.dup_repo_name
cross join lateral (
  values
    ('actor',     c.dup_actor_id,   c.dup_actor_login),
    ('author',    c.author_id,      c.dup_author_login),
    ('committer', c.committer_id,   c.dup_committer_login)
) as v(role, actor_id, actor_login)
where
  {{period:c.dup_created_at}}
  and (lower(v.actor_login) {{exclude_bots}})
  and (v.role = 'actor' or v.actor_id is not null)

union all

select
  rg.repo_group,
  cr.dup_created_at as created_at,
  cr.actor_id,
  lower(cr.actor_login) as actor_login,
  hll_hash_text(cr.sha) as sha_h
from gha_commits_roles cr
join hbus_repo_groups_{{rnd}} rg
  on rg.id = cr.dup_repo_id and rg.name = cr.dup_repo_name
where
  cr.actor_id is not null
  and cr.actor_id != 0
  and cr.role = 'Co-authored-by'
  and {{period:cr.dup_created_at}}
  and (lower(cr.actor_login) {{exclude_bots}})
;

-- Index that can help if planner chooses to drive affiliation join by actor/time
create index on hbus_commits_roles_{{rnd}}(actor_id, created_at);
analyze hbus_commits_roles_{{rnd}};

-- -------------------------
-- 2) Events/comments/issues/merged PRs bases once
--    NOTE: do NOT lower() names here (original keeps original case for usr metrics).
--    Precompute id_h/repo_h once to avoid repeated hashing.
-- -------------------------
create temp table hbus_events_base_{{rnd}} as
select
  rg.repo_group,
  e.created_at,
  e.actor_id,
  e.dup_actor_login as actor_login,
  e.type,
  hll_hash_bigint(e.id) as id_h,
  hll_hash_bigint(e.repo_id) as repo_h
from gha_events e
join hbus_repo_groups_{{rnd}} rg
  on rg.id = e.repo_id and rg.name = e.dup_repo_name
where
  {{period:e.created_at}}
  and (lower(e.dup_actor_login) {{exclude_bots}})
;
create index on hbus_events_base_{{rnd}}(actor_id, created_at);
analyze hbus_events_base_{{rnd}};

create temp table hbus_comments_base_{{rnd}} as
select
  rg.repo_group,
  c.created_at,
  c.user_id as actor_id,
  c.dup_user_login as actor_login,
  hll_hash_bigint(c.id) as id_h
from gha_comments c
join hbus_repo_groups_{{rnd}} rg
  on rg.id = c.dup_repo_id and rg.name = c.dup_repo_name
where
  {{period:c.created_at}}
  and (lower(c.dup_user_login) {{exclude_bots}})
;
create index on hbus_comments_base_{{rnd}}(actor_id, created_at);
analyze hbus_comments_base_{{rnd}};

create temp table hbus_issues_base_{{rnd}} as
select
  rg.repo_group,
  i.created_at,
  i.user_id as actor_id,
  i.dup_user_login as actor_login,
  i.is_pull_request,
  hll_hash_bigint(i.id) as id_h
from gha_issues i
join hbus_repo_groups_{{rnd}} rg
  on rg.id = i.dup_repo_id and rg.name = i.dup_repo_name
where
  {{period:i.created_at}}
  and (lower(i.dup_user_login) {{exclude_bots}})
;
create index on hbus_issues_base_{{rnd}}(actor_id, created_at);
analyze hbus_issues_base_{{rnd}};

create temp table hbus_merged_prs_base_{{rnd}} as
select
  rg.repo_group,
  pr.merged_at,
  pr.user_id as actor_id,
  pr.dup_user_login as actor_login,
  hll_hash_bigint(pr.id) as id_h
from gha_pull_requests pr
join hbus_repo_groups_{{rnd}} rg
  on rg.id = pr.dup_repo_id and rg.name = pr.dup_repo_name
where
  pr.merged_at is not null
  and {{period:pr.merged_at}}
  and (lower(pr.dup_user_login) {{exclude_bots}})
;
create index on hbus_merged_prs_base_{{rnd}}(actor_id, merged_at);
analyze hbus_merged_prs_base_{{rnd}};

-- -------------------------
-- 3) Actor set for the period (reduces affiliation scan dramatically)
-- -------------------------
create temp table hbus_actor_ids_{{rnd}} as
select distinct actor_id
from (
  select actor_id from hbus_commits_roles_{{rnd}} where actor_id is not null and actor_id != 0
  union
  select actor_id from hbus_events_base_{{rnd}}
  union
  select actor_id from hbus_comments_base_{{rnd}}
  union
  select actor_id from hbus_issues_base_{{rnd}}
  union
  select actor_id from hbus_merged_prs_base_{{rnd}}
) s
;
create unique index on hbus_actor_ids_{{rnd}}(actor_id);
analyze hbus_actor_ids_{{rnd}};

-- -------------------------
-- 4) Prefilter affiliations:
--    - only actors in period
--    - only companies used by org metrics
--    - only intervals overlapping [{{from}}, {{to}}) (safe + faster)
-- -------------------------
create temp table hbus_aff_{{rnd}} as
select
  aa.actor_id,
  aa.company_name,
  aa.dt_from,
  aa.dt_to
from gha_actors_affiliations aa
join hbus_actor_ids_{{rnd}} ai
  on ai.actor_id = aa.actor_id
where
  aa.company_name not in ('', 'Independent', '(Robots)')
  and aa.dt_to > '{{from}}'
  and aa.dt_from < '{{to}}'
;
create index on hbus_aff_{{rnd}}(actor_id, dt_from, dt_to);
analyze hbus_aff_{{rnd}};

-- -------------------------
-- 5) Commits_data (left join affiliations like original)
--    Keep duplicates eliminated like original UNION by DISTINCT here.
-- -------------------------
create temp table hbus_commits_data_{{rnd}} as
select distinct
  cr.repo_group,
  cr.actor_login,
  coalesce(a.company_name, '') as company,
  cr.sha_h
from hbus_commits_roles_{{rnd}} cr
left join hbus_aff_{{rnd}} a
  on a.actor_id = cr.actor_id
 and a.dt_from <= cr.created_at
 and a.dt_to > cr.created_at
;
create index on hbus_commits_data_{{rnd}}(repo_group, company);
create index on hbus_commits_data_{{rnd}}(repo_group, actor_login);
analyze hbus_commits_data_{{rnd}};

-- Org-joined datasets (each done once)
create temp table hbus_events_org_{{rnd}} as
select
  e.repo_group,
  a.company_name as company,
  e.type,
  e.id_h,
  e.repo_h
from hbus_events_base_{{rnd}} e
join hbus_aff_{{rnd}} a
  on a.actor_id = e.actor_id
 and a.dt_from <= e.created_at
 and a.dt_to > e.created_at
;
create index on hbus_events_org_{{rnd}}(repo_group, company);
analyze hbus_events_org_{{rnd}};

create temp table hbus_comments_org_{{rnd}} as
select
  c.repo_group,
  a.company_name as company,
  c.id_h
from hbus_comments_base_{{rnd}} c
join hbus_aff_{{rnd}} a
  on a.actor_id = c.actor_id
 and a.dt_from <= c.created_at
 and a.dt_to > c.created_at
;
create index on hbus_comments_org_{{rnd}}(repo_group, company);
analyze hbus_comments_org_{{rnd}};

create temp table hbus_issues_org_{{rnd}} as
select
  i.repo_group,
  a.company_name as company,
  i.is_pull_request,
  i.id_h
from hbus_issues_base_{{rnd}} i
join hbus_aff_{{rnd}} a
  on a.actor_id = i.actor_id
 and a.dt_from <= i.created_at
 and a.dt_to > i.created_at
;
create index on hbus_issues_org_{{rnd}}(repo_group, company);
analyze hbus_issues_org_{{rnd}};

create temp table hbus_merged_prs_org_{{rnd}} as
select
  p.repo_group,
  a.company_name as company,
  p.id_h
from hbus_merged_prs_base_{{rnd}} p
join hbus_aff_{{rnd}} a
  on a.actor_id = p.actor_id
 and a.dt_from <= p.merged_at
 and a.dt_to > p.merged_at
;
create index on hbus_merged_prs_org_{{rnd}}(repo_group, company);
analyze hbus_merged_prs_org_{{rnd}};

-- -------------------------
-- 6) Build per-metric count tables (no WITH; all temp tables)
-- -------------------------

-- Commits (org)
create temp table hbus_commits_org_cnt_{{rnd}} as
select
  case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
  'commits' as metric,
  'org' as tp,
  company as name,
  round(hll_cardinality(hll_add_agg(sha_h))) as cnt
from hbus_commits_data_{{rnd}}
where company not in ('', 'Independent', '(Robots)')
group by grouping sets ((repo_group, company), (company));
analyze hbus_commits_org_cnt_{{rnd}};

-- Commits (usr)
create temp table hbus_commits_usr_cnt_{{rnd}} as
select
  case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
  'commits' as metric,
  'usr' as tp,
  actor_login as name,
  round(hll_cardinality(hll_add_agg(sha_h))) as cnt
from hbus_commits_data_{{rnd}}
group by grouping sets ((repo_group, actor_login), (actor_login));
analyze hbus_commits_usr_cnt_{{rnd}};

-- Events (usr) wide
create temp table hbus_events_usr_agg_{{rnd}} as
select
  case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
  actor_login,
  round(hll_cardinality(hll_add_agg(id_h) filter (
    where type in (
      'IssuesEvent','PullRequestEvent','PushEvent',
      'PullRequestReviewCommentEvent','IssueCommentEvent',
      'CommitCommentEvent','ForkEvent','WatchEvent','PullRequestReviewEvent'
    )
  ))) as contributions,
  round(hll_cardinality(hll_add_agg(id_h) filter (where type='PushEvent'))) as pushes,
  round(hll_cardinality(hll_add_agg(id_h) filter (where type='PullRequestReviewCommentEvent'))) as review_comments,
  round(hll_cardinality(hll_add_agg(id_h) filter (where type='PullRequestReviewEvent'))) as reviews,
  round(hll_cardinality(hll_add_agg(id_h) filter (where type='IssueCommentEvent'))) as issue_comments,
  round(hll_cardinality(hll_add_agg(id_h) filter (where type='CommitCommentEvent'))) as commit_comments,
  round(hll_cardinality(hll_add_agg(repo_h))) as active_repos,
  round(hll_cardinality(hll_add_agg(id_h))) as events
from hbus_events_base_{{rnd}}
group by grouping sets ((repo_group, actor_login), (actor_login));
analyze hbus_events_usr_agg_{{rnd}};

-- Events (usr) unpivot
create temp table hbus_events_usr_cnt_{{rnd}} as
select
  a.repo_group,
  v.metric,
  'usr' as tp,
  a.actor_login as name,
  v.cnt
from hbus_events_usr_agg_{{rnd}} a
cross join lateral (values
  ('contributions',   a.contributions),
  ('pushes',          a.pushes),
  ('review_comments', a.review_comments),
  ('reviews',         a.reviews),
  ('issue_comments',  a.issue_comments),
  ('commit_comments', a.commit_comments),
  ('active_repos',    a.active_repos),
  ('events',          a.events)
) v(metric, cnt)
where v.cnt > 0;
analyze hbus_events_usr_cnt_{{rnd}};

-- Events (org) wide
create temp table hbus_events_org_agg_{{rnd}} as
select
  case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
  company,
  round(hll_cardinality(hll_add_agg(id_h) filter (
    where type in (
      'IssuesEvent','PullRequestEvent','PushEvent',
      'PullRequestReviewCommentEvent','IssueCommentEvent',
      'CommitCommentEvent','ForkEvent','WatchEvent','PullRequestReviewEvent'
    )
  ))) as contributions,
  round(hll_cardinality(hll_add_agg(id_h) filter (where type='PushEvent'))) as pushes,
  round(hll_cardinality(hll_add_agg(id_h) filter (where type='PullRequestReviewCommentEvent'))) as review_comments,
  round(hll_cardinality(hll_add_agg(id_h) filter (where type='PullRequestReviewEvent'))) as reviews,
  round(hll_cardinality(hll_add_agg(id_h) filter (where type='IssueCommentEvent'))) as issue_comments,
  round(hll_cardinality(hll_add_agg(id_h) filter (where type='CommitCommentEvent'))) as commit_comments,
  round(hll_cardinality(hll_add_agg(repo_h))) as active_repos,
  round(hll_cardinality(hll_add_agg(id_h))) as events
from hbus_events_org_{{rnd}}
group by grouping sets ((repo_group, company), (company));
analyze hbus_events_org_agg_{{rnd}};

-- Events (org) unpivot
create temp table hbus_events_org_cnt_{{rnd}} as
select
  a.repo_group,
  v.metric,
  'org' as tp,
  a.company as name,
  v.cnt
from hbus_events_org_agg_{{rnd}} a
cross join lateral (values
  ('contributions',   a.contributions),
  ('pushes',          a.pushes),
  ('review_comments', a.review_comments),
  ('reviews',         a.reviews),
  ('issue_comments',  a.issue_comments),
  ('commit_comments', a.commit_comments),
  ('active_repos',    a.active_repos),
  ('events',          a.events)
) v(metric, cnt)
where v.cnt > 0;
analyze hbus_events_org_cnt_{{rnd}};

-- Comments (usr)
create temp table hbus_comments_usr_cnt_{{rnd}} as
select
  case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
  'comments' as metric,
  'usr' as tp,
  actor_login as name,
  round(hll_cardinality(hll_add_agg(id_h))) as cnt
from hbus_comments_base_{{rnd}}
group by grouping sets ((repo_group, actor_login), (actor_login));
analyze hbus_comments_usr_cnt_{{rnd}};

-- Comments (org)
create temp table hbus_comments_org_cnt_{{rnd}} as
select
  case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
  'comments' as metric,
  'org' as tp,
  company as name,
  round(hll_cardinality(hll_add_agg(id_h))) as cnt
from hbus_comments_org_{{rnd}}
group by grouping sets ((repo_group, company), (company));
analyze hbus_comments_org_cnt_{{rnd}};

-- Issues/PRs (usr) wide
create temp table hbus_issues_usr_agg_{{rnd}} as
select
  case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
  actor_login,
  round(hll_cardinality(hll_add_agg(id_h) filter (where is_pull_request=false))) as issues,
  round(hll_cardinality(hll_add_agg(id_h) filter (where is_pull_request=true)))  as prs
from hbus_issues_base_{{rnd}}
group by grouping sets ((repo_group, actor_login), (actor_login));
analyze hbus_issues_usr_agg_{{rnd}};

create temp table hbus_issues_usr_cnt_{{rnd}} as
select
  a.repo_group,
  v.metric,
  'usr' as tp,
  a.actor_login as name,
  v.cnt
from hbus_issues_usr_agg_{{rnd}} a
cross join lateral (values
  ('issues', a.issues),
  ('prs',    a.prs)
) v(metric, cnt)
where v.cnt > 0;
analyze hbus_issues_usr_cnt_{{rnd}};

-- Issues/PRs (org) wide
create temp table hbus_issues_org_agg_{{rnd}} as
select
  case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
  company,
  round(hll_cardinality(hll_add_agg(id_h) filter (where is_pull_request=false))) as issues,
  round(hll_cardinality(hll_add_agg(id_h) filter (where is_pull_request=true)))  as prs
from hbus_issues_org_{{rnd}}
group by grouping sets ((repo_group, company), (company));
analyze hbus_issues_org_agg_{{rnd}};

create temp table hbus_issues_org_cnt_{{rnd}} as
select
  a.repo_group,
  v.metric,
  'org' as tp,
  a.company as name,
  v.cnt
from hbus_issues_org_agg_{{rnd}} a
cross join lateral (values
  ('issues', a.issues),
  ('prs',    a.prs)
) v(metric, cnt)
where v.cnt > 0;
analyze hbus_issues_org_cnt_{{rnd}};

-- Merged PRs (usr)
create temp table hbus_merged_prs_usr_cnt_{{rnd}} as
select
  case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
  'merged_prs' as metric,
  'usr' as tp,
  actor_login as name,
  round(hll_cardinality(hll_add_agg(id_h))) as cnt
from hbus_merged_prs_base_{{rnd}}
group by grouping sets ((repo_group, actor_login), (actor_login));
analyze hbus_merged_prs_usr_cnt_{{rnd}};

-- Merged PRs (org)
create temp table hbus_merged_prs_org_cnt_{{rnd}} as
select
  case when grouping(repo_group)=1 then 'All' else repo_group end as repo_group,
  'merged_prs' as metric,
  'org' as tp,
  company as name,
  round(hll_cardinality(hll_add_agg(id_h))) as cnt
from hbus_merged_prs_org_{{rnd}}
group by grouping sets ((repo_group, company), (company));
analyze hbus_merged_prs_org_cnt_{{rnd}};

-- -------------------------
-- 7) Union all counts into one table (equivalent to org+urg unions)
-- -------------------------
create temp table hbus_counts_{{rnd}} as
select * from hbus_commits_org_cnt_{{rnd}}
union all select * from hbus_commits_usr_cnt_{{rnd}}
union all select * from hbus_events_org_cnt_{{rnd}}
union all select * from hbus_events_usr_cnt_{{rnd}}
union all select * from hbus_comments_org_cnt_{{rnd}}
union all select * from hbus_comments_usr_cnt_{{rnd}}
union all select * from hbus_issues_org_cnt_{{rnd}}
union all select * from hbus_issues_usr_cnt_{{rnd}}
union all select * from hbus_merged_prs_org_cnt_{{rnd}}
union all select * from hbus_merged_prs_usr_cnt_{{rnd}}
;

create index on hbus_counts_{{rnd}}(repo_group, metric, tp);
analyze hbus_counts_{{rnd}};

-- -------------------------
-- 8) Rank/cumulative/bus factor/top10 (same math & thresholds as original)
-- -------------------------
create temp table hbus_rg_{{rnd}} as
select
  row_number() over (
    partition by repo_group, metric, tp
    order by cnt desc
  ) as row_number,
  repo_group, metric, tp, name, cnt
from hbus_counts_{{rnd}}
;
create index on hbus_rg_{{rnd}}(repo_group, metric, tp, row_number);
analyze hbus_rg_{{rnd}};

create temp table hbus_all_rg_{{rnd}} as
select repo_group, metric, tp, sum(cnt) as cnt
from hbus_rg_{{rnd}}
group by repo_group, metric, tp
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
from hbus_rg_{{rnd}} r
join hbus_all_rg_{{rnd}} ar
  on r.repo_group = ar.repo_group
 and r.metric = ar.metric
 and r.tp = ar.tp
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
from hbus_cum_rg_{{rnd}}
where cumulative_percent > 50.0
group by repo_group, metric, tp
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
    where cr.repo_group = b.repo_group
      and cr.metric = b.metric
      and cr.tp = b.tp
      and cr.row_number <= b.bus_factor
      and cr.row_number <= 10
  ) as companies,
  b.others_count,
  b.others_percent
from hbus_bf_{{rnd}} b
;
create index on hbus_bfa_{{rnd}}(repo_group, metric, tp);
analyze hbus_bfa_{{rnd}};

create temp table hbus_top_{{rnd}} as
select
  repo_group,
  metric,
  tp,
  max(row_number) as top_n,
  max(cumulative_percent) as top_percent,
  100.0 - max(cumulative_percent) as non_top_percent
from hbus_cum_rg_{{rnd}}
where row_number <= 10
group by repo_group, metric, tp
;
create index on hbus_top_{{rnd}}(repo_group, metric, tp);
analyze hbus_top_{{rnd}};

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
    where cr.repo_group = t.repo_group
      and cr.metric = t.metric
      and cr.tp = t.tp
      and cr.row_number <= t.top_n
  ) as companies,
  t.non_top_percent
from hbus_top_{{rnd}} t
;
create index on hbus_topa_{{rnd}}(repo_group, metric, tp);
analyze hbus_topa_{{rnd}};

-- -------------------------
-- 9) Final output (exact same shape as original)
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
from hbus_bfa_{{rnd}} b
join hbus_topa_{{rnd}} t
  on b.repo_group = t.repo_group
 and b.metric = t.metric
 and b.tp = t.tp
;

