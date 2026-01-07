-- kprs.sql
-- Repo-level "pstat" metrics optimized for large data volumes.
-- Key optimizations:
-- 1) Scan big base tables only once per entity (events/commits/comments/issues/reviews)
-- 2) Materialize trepos list once and JOIN (avoid repeated IN (SELECT ...))
-- 3) Pre-filter bot-excluded events into a temp table derived from the already materialized period table
-- 4) Aggregate once and reuse (avoid N repeated full-table scans)
--
-- Semantics: matches your original query output/rows (including when per-repo rows should/shouldn't exist).

-- 0) trepos distinct
create temp table trepos_{{rnd}} as (
  select distinct
    repo_name
  from
    trepos
);
create index on trepos_{{rnd}}(repo_name);
analyze trepos_{{rnd}};

-- 1) EVENTS: scan once for period, then derive non-bot subset from the temp table (no 2nd scan of gha_events)
create temp table events_p_{{rnd}} as (
  select
    e.id,
    e.repo_id,
    e.dup_repo_name as repo_name,
    e.type,
    e.actor_id,
    e.dup_actor_login
  from
    gha_events e
  where
    {{period:e.created_at}}
);
create index on events_p_{{rnd}}(repo_name);
create index on events_p_{{rnd}}(type);
create index on events_p_{{rnd}}(repo_id);
analyze events_p_{{rnd}};

create temp table events_nb_{{rnd}} as (
  select
    *
  from
    events_p_{{rnd}}
  where
    (lower(dup_actor_login) {{exclude_bots}})
);
create index on events_nb_{{rnd}}(repo_name);
create index on events_nb_{{rnd}}(type);
create index on events_nb_{{rnd}}(actor_id);
analyze events_nb_{{rnd}};

-- 1a) Per-repo subsets
create temp table events_p_trepos_{{rnd}} as (
  select
    e.*
  from
    events_p_{{rnd}} e
  join
    trepos_{{rnd}} t
  on
    t.repo_name = e.repo_name
);
create index on events_p_trepos_{{rnd}}(repo_name);
create index on events_p_trepos_{{rnd}}(repo_id);
analyze events_p_trepos_{{rnd}};

create temp table events_nb_trepos_{{rnd}} as (
  select
    e.*
  from
    events_nb_{{rnd}} e
  join
    trepos_{{rnd}} t
  on
    t.repo_name = e.repo_name
);
create index on events_nb_trepos_{{rnd}}(repo_name);
create index on events_nb_trepos_{{rnd}}(repo_name, type);
analyze events_nb_trepos_{{rnd}};

-- 2) Contributions-type events (for Contributors/Contributions/Pushes), both all + trepos
create temp table events_contrib_nb_all_{{rnd}} as (
  select
    id,
    repo_name,
    type,
    dup_actor_login
  from
    events_nb_{{rnd}}
  where
    type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
);
create index on events_contrib_nb_all_{{rnd}}(type);
analyze events_contrib_nb_all_{{rnd}};

create temp table events_contrib_nb_trepos_{{rnd}} as (
  select
    id,
    repo_name,
    type,
    dup_actor_login
  from
    events_nb_trepos_{{rnd}}
  where
    type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
);
create index on events_contrib_nb_trepos_{{rnd}}(repo_name);
create index on events_contrib_nb_trepos_{{rnd}}(repo_name, type);
analyze events_contrib_nb_trepos_{{rnd}};

create temp table contrib_repo_agg_{{rnd}} as (
  select
    repo_name,
    count(distinct dup_actor_login) as contributors,
    count(distinct id) as contributions,
    count(distinct id) filter (where type = 'PushEvent') as pushes
  from
    events_contrib_nb_trepos_{{rnd}}
  group by
    repo_name
);
create index on contrib_repo_agg_{{rnd}}(repo_name);
analyze contrib_repo_agg_{{rnd}};

create temp table contrib_all_agg_{{rnd}} as (
  select
    count(distinct dup_actor_login) as contributors,
    count(distinct id) as contributions,
    count(distinct id) filter (where type = 'PushEvent') as pushes
  from
    events_contrib_nb_all_{{rnd}}
);
analyze contrib_all_agg_{{rnd}};

-- 3) Events counts (bots excluded)
create temp table events_repo_agg_{{rnd}} as (
  select
    repo_name,
    count(*)::bigint as events
  from
    events_nb_trepos_{{rnd}}
  group by
    repo_name
);
create index on events_repo_agg_{{rnd}}(repo_name);
analyze events_repo_agg_{{rnd}};

create temp table events_all_agg_{{rnd}} as (
  select
    count(*)::bigint as events
  from
    events_nb_{{rnd}}
);
analyze events_all_agg_{{rnd}};

-- 4) Event-type actor metrics (bots excluded)
create temp table evtype_repo_agg_{{rnd}} as (
  select
    repo_name,
    type,
    count(distinct actor_id) as value
  from
    events_nb_trepos_{{rnd}}
  where
    type in (
      'IssuesEvent', 'PullRequestEvent', 'PushEvent',
      'PullRequestReviewCommentEvent', 'IssueCommentEvent',
      'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
    )
  group by
    repo_name,
    type
);
create index on evtype_repo_agg_{{rnd}}(repo_name, type);
analyze evtype_repo_agg_{{rnd}};

create temp table evtype_all_agg_{{rnd}} as (
  select
    type,
    count(distinct actor_id) as value
  from
    events_nb_{{rnd}}
  where
    type in (
      'IssuesEvent', 'PullRequestEvent', 'PushEvent',
      'PullRequestReviewCommentEvent', 'IssueCommentEvent',
      'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
    )
  group by
    type
);
create index on evtype_all_agg_{{rnd}}(type);
analyze evtype_all_agg_{{rnd}};

-- 5) Repositories (bots INCLUDED, per original)
create temp table repos_repo_agg_{{rnd}} as (
  select
    repo_name,
    count(distinct repo_id) as value
  from
    events_p_trepos_{{rnd}}
  group by
    repo_name
);
create index on repos_repo_agg_{{rnd}}(repo_name);
analyze repos_repo_agg_{{rnd}};

create temp table repos_all_agg_{{rnd}} as (
  select
    count(distinct repo_id) as value
  from
    events_p_{{rnd}}
);
analyze repos_all_agg_{{rnd}};

-- 6) COMMITS: scan once, then expand roles (matches your union semantics; distinct counts make UNION vs UNION ALL irrelevant)
create temp table commits_p_{{rnd}} as (
  select
    c.sha,
    c.dup_repo_name as repo_name,
    c.dup_actor_id,
    c.dup_actor_login,
    c.author_id,
    c.dup_author_login,
    c.committer_id,
    c.dup_committer_login
  from
    gha_commits c
  where
    {{period:c.dup_created_at}}
);
create index on commits_p_{{rnd}}(repo_name);
analyze commits_p_{{rnd}};

create temp table commits_data_{{rnd}} as (
  select
    c.repo_name,
    c.sha,
    v.actor_id
  from
    commits_p_{{rnd}} c
  cross join lateral (
    values
      (c.dup_actor_id, c.dup_actor_login, true),
      (c.author_id, c.dup_author_login, c.author_id is not null),
      (c.committer_id, c.dup_committer_login, c.committer_id is not null)
  ) v(actor_id, actor_login, include_row)
  where
    v.include_row
    and (lower(v.actor_login) {{exclude_bots}})
);
create index on commits_data_{{rnd}}(repo_name);
analyze commits_data_{{rnd}};

create temp table commits_repo_agg_{{rnd}} as (
  select
    c.repo_name,
    count(distinct c.sha) as commits,
    count(distinct c.actor_id) as committers
  from
    commits_data_{{rnd}} c
  join
    trepos_{{rnd}} t
  on
    t.repo_name = c.repo_name
  group by
    c.repo_name
);
create index on commits_repo_agg_{{rnd}}(repo_name);
analyze commits_repo_agg_{{rnd}};

create temp table commits_all_agg_{{rnd}} as (
  select
    count(distinct sha) as commits,
    count(distinct actor_id) as committers
  from
    commits_data_{{rnd}}
);
analyze commits_all_agg_{{rnd}};

-- 7) COMMENTS (bots excluded)
create temp table comments_nb_all_{{rnd}} as (
  select
    c.id,
    c.dup_repo_name as repo_name,
    c.user_id
  from
    gha_comments c
  where
    {{period:c.created_at}}
    and (lower(c.dup_user_login) {{exclude_bots}})
);
create index on comments_nb_all_{{rnd}}(repo_name);
analyze comments_nb_all_{{rnd}};

create temp table comments_nb_trepos_{{rnd}} as (
  select
    c.*
  from
    comments_nb_all_{{rnd}} c
  join
    trepos_{{rnd}} t
  on
    t.repo_name = c.repo_name
);
create index on comments_nb_trepos_{{rnd}}(repo_name);
analyze comments_nb_trepos_{{rnd}};

create temp table comments_repo_agg_{{rnd}} as (
  select
    repo_name,
    count(distinct id) as comments,
    count(distinct user_id) as commenters
  from
    comments_nb_trepos_{{rnd}}
  group by
    repo_name
);
create index on comments_repo_agg_{{rnd}}(repo_name);
analyze comments_repo_agg_{{rnd}};

create temp table comments_all_agg_{{rnd}} as (
  select
    count(distinct id) as comments,
    count(distinct user_id) as commenters
  from
    comments_nb_all_{{rnd}}
);
analyze comments_all_agg_{{rnd}};

-- 8) REVIEWS (bots excluded)
create temp table reviews_nb_all_{{rnd}} as (
  select
    r.id,
    r.dup_repo_name as repo_name
  from
    gha_reviews r
  where
    {{period:r.submitted_at}}
    and (lower(r.dup_user_login) {{exclude_bots}})
);
create index on reviews_nb_all_{{rnd}}(repo_name);
analyze reviews_nb_all_{{rnd}};

create temp table reviews_nb_trepos_{{rnd}} as (
  select
    r.*
  from
    reviews_nb_all_{{rnd}} r
  join
    trepos_{{rnd}} t
  on
    t.repo_name = r.repo_name
);
create index on reviews_nb_trepos_{{rnd}}(repo_name);
analyze reviews_nb_trepos_{{rnd}};

create temp table reviews_repo_agg_{{rnd}} as (
  select
    repo_name,
    count(distinct id) as value
  from
    reviews_nb_trepos_{{rnd}}
  group by
    repo_name
);
create index on reviews_repo_agg_{{rnd}}(repo_name);
analyze reviews_repo_agg_{{rnd}};

create temp table reviews_all_agg_{{rnd}} as (
  select
    count(distinct id) as value
  from
    reviews_nb_all_{{rnd}}
);
analyze reviews_all_agg_{{rnd}};

-- 9) ISSUES / PRS (bots excluded)
create temp table issues_nb_all_{{rnd}} as (
  select
    i.id,
    i.dup_repo_name as repo_name,
    i.is_pull_request
  from
    gha_issues i
  where
    {{period:i.created_at}}
    and (lower(i.dup_user_login) {{exclude_bots}})
);
create index on issues_nb_all_{{rnd}}(repo_name);
create index on issues_nb_all_{{rnd}}(is_pull_request);
analyze issues_nb_all_{{rnd}};

create temp table issues_nb_trepos_{{rnd}} as (
  select
    i.*
  from
    issues_nb_all_{{rnd}} i
  join
    trepos_{{rnd}} t
  on
    t.repo_name = i.repo_name
);
create index on issues_nb_trepos_{{rnd}}(repo_name);
create index on issues_nb_trepos_{{rnd}}(is_pull_request);
analyze issues_nb_trepos_{{rnd}};

create temp table issues_repo_agg_{{rnd}} as (
  select
    repo_name,
    count(distinct id) filter (where is_pull_request = false) as issues,
    count(distinct id) filter (where is_pull_request = true) as prs
  from
    issues_nb_trepos_{{rnd}}
  group by
    repo_name
);
create index on issues_repo_agg_{{rnd}}(repo_name);
analyze issues_repo_agg_{{rnd}};

create temp table issues_all_agg_{{rnd}} as (
  select
    count(distinct id) filter (where is_pull_request = false) as issues,
    count(distinct id) filter (where is_pull_request = true) as prs
  from
    issues_nb_all_{{rnd}}
);
analyze issues_all_agg_{{rnd}};

-- 10) FINAL OUTPUT (matches original row presence rules)
select
  repo,
  name,
  value
from (
  -- Contributors (per repo only when exists in original => repo had >=1 contrib-type event)
  select
    'pstat,' || repo_name as repo,
    'Contributors' as name,
    contributors as value
  from
    contrib_repo_agg_{{rnd}}
  where
    contributors > 0

  union all

  select
    'pstat,All' as repo,
    'Contributors' as name,
    contributors as value
  from
    contrib_all_agg_{{rnd}}

  union all

  -- Contributions (same row presence as above)
  select
    'pstat,' || repo_name as repo,
    'Contributions' as name,
    contributions as value
  from
    contrib_repo_agg_{{rnd}}
  where
    contributions > 0

  union all

  select
    'pstat,All' as repo,
    'Contributions' as name,
    contributions as value
  from
    contrib_all_agg_{{rnd}}

  union all

  -- Pushes (only when a repo had pushes, like original)
  select
    'pstat,' || repo_name as repo,
    'Pushes' as name,
    pushes as value
  from
    contrib_repo_agg_{{rnd}}
  where
    pushes > 0

  union all

  select
    'pstat,All' as repo,
    'Pushes' as name,
    pushes as value
  from
    contrib_all_agg_{{rnd}}

  union all

  -- Commits
  select
    'pstat,' || repo_name as repo,
    'Commits' as name,
    commits as value
  from
    commits_repo_agg_{{rnd}}

  union all

  select
    'pstat,All' as repo,
    'Commits' as name,
    commits as value
  from
    commits_all_agg_{{rnd}}

  union all

  -- Code committers
  select
    'pstat,' || repo_name as repo,
    'Code committers' as name,
    committers as value
  from
    commits_repo_agg_{{rnd}}

  union all

  select
    'pstat,All' as repo,
    'Code committers' as name,
    committers as value
  from
    commits_all_agg_{{rnd}}

  union all

  -- Event-type actor metrics per repo
  select
    'pstat,' || repo_name as repo,
    case type
      when 'IssuesEvent' then 'Issue creators'
      when 'PullRequestEvent' then 'PR creators'
      when 'PushEvent' then 'Pushers'
      when 'PullRequestReviewCommentEvent' then 'PR review commenters'
      when 'PullRequestReviewEvent' then 'PR reviewers'
      when 'IssueCommentEvent' then 'Issue commenters'
      when 'CommitCommentEvent' then 'Commit commenters'
      when 'WatchEvent' then 'Stargazers'
      when 'ForkEvent' then 'Forkers'
    end as name,
    value
  from
    evtype_repo_agg_{{rnd}}

  union all

  -- Event-type actor metrics all
  select
    'pstat,All' as repo,
    case type
      when 'IssuesEvent' then 'Issue creators'
      when 'PullRequestEvent' then 'PR creators'
      when 'PushEvent' then 'Pushers'
      when 'PullRequestReviewCommentEvent' then 'PR review commenters'
      when 'PullRequestReviewEvent' then 'PR reviewers'
      when 'IssueCommentEvent' then 'Issue commenters'
      when 'CommitCommentEvent' then 'Commit commenters'
      when 'WatchEvent' then 'Stargazers'
      when 'ForkEvent' then 'Forkers'
    end as name,
    value
  from
    evtype_all_agg_{{rnd}}

  union all

  -- Repositories (bots INCLUDED)
  select
    'pstat,' || repo_name as repo,
    'Repositories' as name,
    value
  from
    repos_repo_agg_{{rnd}}

  union all

  select
    'pstat,All' as repo,
    'Repositories' as name,
    value
  from
    repos_all_agg_{{rnd}}

  union all

  -- Comments
  select
    'pstat,' || repo_name as repo,
    'Comments' as name,
    comments as value
  from
    comments_repo_agg_{{rnd}}

  union all

  select
    'pstat,All' as repo,
    'Comments' as name,
    comments as value
  from
    comments_all_agg_{{rnd}}

  union all

  -- Commenters
  select
    'pstat,' || repo_name as repo,
    'Commenters' as name,
    commenters as value
  from
    comments_repo_agg_{{rnd}}

  union all

  select
    'pstat,All' as repo,
    'Commenters' as name,
    commenters as value
  from
    comments_all_agg_{{rnd}}

  union all

  -- PR reviews
  select
    'pstat,' || repo_name as repo,
    'PR reviews' as name,
    value
  from
    reviews_repo_agg_{{rnd}}

  union all

  select
    'pstat,All' as repo,
    'PR reviews' as name,
    value
  from
    reviews_all_agg_{{rnd}}

  union all

  -- Issues (only per repo when >0, like original WHERE is_pull_request=false)
  select
    'pstat,' || repo_name as repo,
    'Issues' as name,
    issues as value
  from
    issues_repo_agg_{{rnd}}
  where
    issues > 0

  union all

  select
    'pstat,All' as repo,
    'Issues' as name,
    issues as value
  from
    issues_all_agg_{{rnd}}

  union all

  -- PRs (only per repo when >0, like original WHERE is_pull_request=true)
  select
    'pstat,' || repo_name as repo,
    'PRs' as name,
    prs as value
  from
    issues_repo_agg_{{rnd}}
  where
    prs > 0

  union all

  select
    'pstat,All' as repo,
    'PRs' as name,
    prs as value
  from
    issues_all_agg_{{rnd}}

  union all

  -- Events (bots excluded)
  select
    'pstat,' || repo_name as repo,
    'Events' as name,
    events as value
  from
    events_repo_agg_{{rnd}}

  union all

  select
    'pstat,All' as repo,
    'Events' as name,
    events as value
  from
    events_all_agg_{{rnd}}
) out
order by
  name asc,
  value desc,
  repo asc
;

