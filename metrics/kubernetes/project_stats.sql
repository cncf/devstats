-- kprs.sql
-- Optimized for large datasets by:
-- - materializing period-limited base tables once
-- - limiting gha_events_commits_files scans to relevant event_ids only
-- - reusing derived tables for multiple metrics
-- IMPORTANT: Do NOT use reserved keywords as aliases (e.g. "any" in Postgres).

create temp table repos_{{rnd}} as (
  select
    id as repo_id,
    name as repo_name,
    repo_group
  from
    gha_repos
);
create index on repos_{{rnd}}(repo_id, repo_name);
create index on repos_{{rnd}}(repo_group);
analyze repos_{{rnd}};

create temp table events_nb_{{rnd}} as (
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
    and (lower(e.dup_actor_login) {{exclude_bots}})
);
create index on events_nb_{{rnd}}(repo_id, repo_name);
create index on events_nb_{{rnd}}(type);
create index on events_nb_{{rnd}}(actor_id);
analyze events_nb_{{rnd}};

create temp table events_all_{{rnd}} as (
  select
    e.id,
    e.repo_id,
    e.dup_repo_name as repo_name
  from
    gha_events e
  where
    {{period:e.created_at}}
);
create index on events_all_{{rnd}}(repo_id, repo_name);
analyze events_all_{{rnd}};

create temp table commits_p_{{rnd}} as (
  select
    c.sha,
    c.dup_repo_id,
    c.dup_repo_name,
    c.event_id,
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
create index on commits_p_{{rnd}}(dup_repo_id, dup_repo_name);
create index on commits_p_{{rnd}}(event_id);
analyze commits_p_{{rnd}};

create temp table comments_nb_{{rnd}} as (
  select
    c.id,
    c.dup_repo_id,
    c.dup_repo_name,
    c.user_id,
    c.event_id
  from
    gha_comments c
  where
    {{period:c.created_at}}
    and (lower(c.dup_user_login) {{exclude_bots}})
);
create index on comments_nb_{{rnd}}(dup_repo_id, dup_repo_name);
create index on comments_nb_{{rnd}}(event_id);
analyze comments_nb_{{rnd}};

create temp table issues_nb_{{rnd}} as (
  select
    i.id,
    i.dup_repo_id,
    i.dup_repo_name,
    i.user_id,
    i.event_id,
    i.is_pull_request
  from
    gha_issues i
  where
    {{period:i.created_at}}
    and (lower(i.dup_user_login) {{exclude_bots}})
);
create index on issues_nb_{{rnd}}(dup_repo_id, dup_repo_name);
create index on issues_nb_{{rnd}}(event_id);
create index on issues_nb_{{rnd}}(is_pull_request);
analyze issues_nb_{{rnd}};

create temp table reviews_nb_{{rnd}} as (
  select
    r.id,
    r.dup_repo_id,
    r.dup_repo_name,
    r.event_id
  from
    gha_reviews r
  where
    {{period:r.submitted_at}}
    and (lower(r.dup_user_login) {{exclude_bots}})
);
create index on reviews_nb_{{rnd}}(dup_repo_id, dup_repo_name);
create index on reviews_nb_{{rnd}}(event_id);
analyze reviews_nb_{{rnd}};

create temp table all_event_ids_{{rnd}} as (
  select id as event_id from events_nb_{{rnd}}
  union
  select event_id from commits_p_{{rnd}} where event_id is not null
  union
  select event_id from comments_nb_{{rnd}} where event_id is not null
  union
  select event_id from issues_nb_{{rnd}} where event_id is not null
  union
  select event_id from reviews_nb_{{rnd}} where event_id is not null
);
create index on all_event_ids_{{rnd}}(event_id);
analyze all_event_ids_{{rnd}};

create temp table ecf_ev_grp_cnt_{{rnd}} as (
  select
    ecf.event_id,
    ecf.repo_group,
    count(*) as cnt
  from
    gha_events_commits_files ecf
  join
    all_event_ids_{{rnd}} a
  on
    a.event_id = ecf.event_id
  group by
    ecf.event_id,
    ecf.repo_group
);
create index on ecf_ev_grp_cnt_{{rnd}}(event_id);
create index on ecf_ev_grp_cnt_{{rnd}}(event_id, repo_group);
analyze ecf_ev_grp_cnt_{{rnd}};

create temp table ecf_event_any_{{rnd}} as (
  select distinct
    event_id
  from
    ecf_ev_grp_cnt_{{rnd}}
);
create index on ecf_event_any_{{rnd}}(event_id);
analyze ecf_event_any_{{rnd}};

create temp table ecf_event_hasnull_{{rnd}} as (
  select distinct
    event_id
  from
    ecf_ev_grp_cnt_{{rnd}}
  where
    repo_group is null
);
create index on ecf_event_hasnull_{{rnd}}(event_id);
analyze ecf_event_hasnull_{{rnd}};

create temp table ecf_event_groups_{{rnd}} as (
  select
    event_id,
    repo_group
  from
    ecf_ev_grp_cnt_{{rnd}}
  where
    repo_group is not null
);
create index on ecf_event_groups_{{rnd}}(event_id, repo_group);
analyze ecf_event_groups_{{rnd}};

create temp table events_nb_base_{{rnd}} as (
  select
    e.id,
    e.type,
    e.actor_id,
    e.dup_actor_login,
    r.repo_group as repo_group_base
  from
    events_nb_{{rnd}} e
  join
    repos_{{rnd}} r
  on
    e.repo_id = r.repo_id
    and e.repo_name = r.repo_name
);
create index on events_nb_base_{{rnd}}(id);
create index on events_nb_base_{{rnd}}(repo_group_base);
analyze events_nb_base_{{rnd}};

create temp table event_repo_groups_{{rnd}} as (
  select
    event_id,
    repo_group
  from
    ecf_event_groups_{{rnd}}

  union

  select
    e.id as event_id,
    e.repo_group_base as repo_group
  from
    events_nb_base_{{rnd}} e
  left join
    ecf_event_any_{{rnd}} ea
  on
    ea.event_id = e.id
  left join
    ecf_event_hasnull_{{rnd}} hn
  on
    hn.event_id = e.id
  where
    ea.event_id is null
    or hn.event_id is not null
);
create index on event_repo_groups_{{rnd}}(event_id);
create index on event_repo_groups_{{rnd}}(repo_group);
analyze event_repo_groups_{{rnd}};

create temp table events_nb_rg_{{rnd}} as (
  select
    'pstat,' || g.repo_group as repo_group,
    e.id,
    e.type,
    e.actor_id,
    e.dup_actor_login
  from
    event_repo_groups_{{rnd}} g
  join
    events_nb_base_{{rnd}} e
  on
    e.id = g.event_id
  where
    g.repo_group is not null
);
create index on events_nb_rg_{{rnd}}(repo_group);
create index on events_nb_rg_{{rnd}}(repo_group, type);
create index on events_nb_rg_{{rnd}}(type);
analyze events_nb_rg_{{rnd}};

create temp table events_rg_agg_{{rnd}} as (
  select
    repo_group,
    count(*) filter (
      where type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
    ) as cnt_contrib,
    count(*) filter (where type = 'PushEvent') as cnt_push,
    count(distinct dup_actor_login) filter (
      where type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
    ) as contributors,
    count(distinct id) filter (
      where type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
    ) as contributions,
    count(distinct id) filter (where type = 'PushEvent') as pushes
  from
    events_nb_rg_{{rnd}}
  group by
    repo_group
);
create index on events_rg_agg_{{rnd}}(repo_group);
analyze events_rg_agg_{{rnd}};

create temp table events_all_agg_{{rnd}} as (
  select
    count(distinct dup_actor_login) filter (
      where type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
    ) as contributors,
    count(distinct id) filter (
      where type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
    ) as contributions,
    count(distinct id) filter (where type = 'PushEvent') as pushes,
    count(id) as events
  from
    events_nb_{{rnd}}
);
analyze events_all_agg_{{rnd}};

create temp table events_rg_events_{{rnd}} as (
  select
    'pstat,' || repo_group as repo_group,
    sum(cnt)::bigint as events
  from (
    select
      coalesce(ecf.repo_group, e.repo_group_base) as repo_group,
      sum(ecf.cnt) as cnt
    from
      events_nb_base_{{rnd}} e
    join
      ecf_ev_grp_cnt_{{rnd}} ecf
    on
      ecf.event_id = e.id
    group by
      coalesce(ecf.repo_group, e.repo_group_base)

    union all

    select
      e.repo_group_base as repo_group,
      count(*) as cnt
    from
      events_nb_base_{{rnd}} e
    left join
      ecf_event_any_{{rnd}} ea
    on
      ea.event_id = e.id
    where
      ea.event_id is null
    group by
      e.repo_group_base
  ) s
  where
    repo_group is not null
  group by
    repo_group
);
create index on events_rg_events_{{rnd}}(repo_group);
analyze events_rg_events_{{rnd}};

create temp table evtype_rg_agg_{{rnd}} as (
  select
    repo_group,
    type,
    count(distinct actor_id) as value
  from
    events_nb_rg_{{rnd}}
  where
    type in (
      'IssuesEvent', 'PullRequestEvent', 'PushEvent',
      'PullRequestReviewCommentEvent', 'IssueCommentEvent',
      'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
    )
  group by
    repo_group,
    type
);
create index on evtype_rg_agg_{{rnd}}(repo_group, type);
analyze evtype_rg_agg_{{rnd}};

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
analyze evtype_all_agg_{{rnd}};

create temp table repos_all_agg_{{rnd}} as (
  select
    count(distinct repo_id) as value
  from
    events_all_{{rnd}}
);
analyze repos_all_agg_{{rnd}};

create temp table repos_rg_agg_{{rnd}} as (
  select
    'pstat,' || r.repo_group as repo_group,
    count(distinct e.repo_id) as value
  from
    events_all_{{rnd}} e
  join
    repos_{{rnd}} r
  on
    e.repo_id = r.repo_id
    and e.repo_name = r.repo_name
  where
    r.repo_group is not null
  group by
    r.repo_group
);
create index on repos_rg_agg_{{rnd}}(repo_group);
analyze repos_rg_agg_{{rnd}};

create temp table commits_base_{{rnd}} as (
  select
    c.sha,
    c.event_id,
    r.repo_group as repo_group_base,
    v.actor_id
  from
    commits_p_{{rnd}} c
  join
    repos_{{rnd}} r
  on
    c.dup_repo_id = r.repo_id
    and c.dup_repo_name = r.repo_name
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
create index on commits_base_{{rnd}}(event_id);
create index on commits_base_{{rnd}}(repo_group_base);
analyze commits_base_{{rnd}};

create temp table commits_data_{{rnd}} as (
  select
    case when repo_group is null then null else 'pstat,' || repo_group end as repo_group,
    sha,
    actor_id
  from (
    select
      ecf.repo_group as repo_group,
      b.sha,
      b.actor_id
    from
      commits_base_{{rnd}} b
    join
      ecf_event_groups_{{rnd}} ecf
    on
      ecf.event_id = b.event_id

    union all

    select
      b.repo_group_base as repo_group,
      b.sha,
      b.actor_id
    from
      commits_base_{{rnd}} b
    left join
      ecf_event_any_{{rnd}} ea
    on
      ea.event_id = b.event_id
    left join
      ecf_event_hasnull_{{rnd}} hn
    on
      hn.event_id = b.event_id
    where
      ea.event_id is null
      or hn.event_id is not null
  ) s
);
create index on commits_data_{{rnd}}(repo_group);
analyze commits_data_{{rnd}};

create temp table commits_agg_{{rnd}} as (
  select
    repo_group,
    grouping(repo_group) as grp_level,
    count(distinct sha) as commits,
    count(distinct actor_id) as committers
  from
    commits_data_{{rnd}}
  group by
    grouping sets ((repo_group), ())
);
create index on commits_agg_{{rnd}}(grp_level, repo_group);
analyze commits_agg_{{rnd}};

create temp table comments_base_{{rnd}} as (
  select
    c.id,
    c.user_id,
    c.event_id,
    r.repo_group as repo_group_base
  from
    comments_nb_{{rnd}} c
  join
    repos_{{rnd}} r
  on
    c.dup_repo_id = r.repo_id
    and c.dup_repo_name = r.repo_name
);
create index on comments_base_{{rnd}}(event_id);
create index on comments_base_{{rnd}}(repo_group_base);
analyze comments_base_{{rnd}};

create temp table comments_data_{{rnd}} as (
  select
    case when repo_group is null then null else 'pstat,' || repo_group end as repo_group,
    id,
    user_id
  from (
    select
      ecf.repo_group as repo_group,
      c.id,
      c.user_id
    from
      comments_base_{{rnd}} c
    join
      ecf_event_groups_{{rnd}} ecf
    on
      ecf.event_id = c.event_id

    union all

    select
      c.repo_group_base as repo_group,
      c.id,
      c.user_id
    from
      comments_base_{{rnd}} c
    left join
      ecf_event_any_{{rnd}} ea
    on
      ea.event_id = c.event_id
    left join
      ecf_event_hasnull_{{rnd}} hn
    on
      hn.event_id = c.event_id
    where
      ea.event_id is null
      or hn.event_id is not null
  ) s
);
create index on comments_data_{{rnd}}(repo_group);
analyze comments_data_{{rnd}};

create temp table comments_rg_agg_{{rnd}} as (
  select
    repo_group,
    count(distinct id) as comments,
    count(distinct user_id) as commenters
  from
    comments_data_{{rnd}}
  where
    repo_group is not null
  group by
    repo_group
);
create index on comments_rg_agg_{{rnd}}(repo_group);
analyze comments_rg_agg_{{rnd}};

create temp table comments_all_agg_{{rnd}} as (
  select
    count(distinct id) as comments,
    count(distinct user_id) as commenters
  from
    comments_nb_{{rnd}}
);
analyze comments_all_agg_{{rnd}};

create temp table issues_base_{{rnd}} as (
  select
    i.id,
    i.is_pull_request,
    i.event_id,
    r.repo_group as repo_group_base
  from
    issues_nb_{{rnd}} i
  join
    repos_{{rnd}} r
  on
    i.dup_repo_id = r.repo_id
    and i.dup_repo_name = r.repo_name
);
create index on issues_base_{{rnd}}(event_id);
create index on issues_base_{{rnd}}(repo_group_base);
create index on issues_base_{{rnd}}(is_pull_request);
analyze issues_base_{{rnd}};

create temp table issues_data_{{rnd}} as (
  select
    case when repo_group is null then null else 'pstat,' || repo_group end as repo_group,
    id,
    is_pull_request
  from (
    select
      ecf.repo_group as repo_group,
      i.id,
      i.is_pull_request
    from
      issues_base_{{rnd}} i
    join
      ecf_event_groups_{{rnd}} ecf
    on
      ecf.event_id = i.event_id

    union all

    select
      i.repo_group_base as repo_group,
      i.id,
      i.is_pull_request
    from
      issues_base_{{rnd}} i
    left join
      ecf_event_any_{{rnd}} ea
    on
      ea.event_id = i.event_id
    left join
      ecf_event_hasnull_{{rnd}} hn
    on
      hn.event_id = i.event_id
    where
      ea.event_id is null
      or hn.event_id is not null
  ) s
);
create index on issues_data_{{rnd}}(repo_group);
create index on issues_data_{{rnd}}(is_pull_request);
analyze issues_data_{{rnd}};

create temp table issues_rg_agg_{{rnd}} as (
  select
    repo_group,
    count(*) filter (where is_pull_request = false) as cnt_issues,
    count(*) filter (where is_pull_request = true) as cnt_prs,
    count(distinct id) filter (where is_pull_request = false) as issues,
    count(distinct id) filter (where is_pull_request = true) as prs
  from
    issues_data_{{rnd}}
  where
    repo_group is not null
  group by
    repo_group
);
create index on issues_rg_agg_{{rnd}}(repo_group);
analyze issues_rg_agg_{{rnd}};

create temp table issues_all_agg_{{rnd}} as (
  select
    count(distinct id) filter (where is_pull_request = false) as issues,
    count(distinct id) filter (where is_pull_request = true) as prs
  from
    issues_nb_{{rnd}}
);
analyze issues_all_agg_{{rnd}};

create temp table reviews_base_{{rnd}} as (
  select
    rv.id,
    rv.event_id,
    r.repo_group as repo_group_base
  from
    reviews_nb_{{rnd}} rv
  join
    repos_{{rnd}} r
  on
    rv.dup_repo_id = r.repo_id
    and rv.dup_repo_name = r.repo_name
);
create index on reviews_base_{{rnd}}(event_id);
create index on reviews_base_{{rnd}}(repo_group_base);
analyze reviews_base_{{rnd}};

create temp table reviews_data_{{rnd}} as (
  select
    case when repo_group is null then null else 'pstat,' || repo_group end as repo_group,
    id
  from (
    select
      ecf.repo_group as repo_group,
      rv.id
    from
      reviews_base_{{rnd}} rv
    join
      ecf_event_groups_{{rnd}} ecf
    on
      ecf.event_id = rv.event_id

    union all

    select
      rv.repo_group_base as repo_group,
      rv.id
    from
      reviews_base_{{rnd}} rv
    left join
      ecf_event_any_{{rnd}} ea
    on
      ea.event_id = rv.event_id
    left join
      ecf_event_hasnull_{{rnd}} hn
    on
      hn.event_id = rv.event_id
    where
      ea.event_id is null
      or hn.event_id is not null
  ) s
);
create index on reviews_data_{{rnd}}(repo_group);
analyze reviews_data_{{rnd}};

create temp table reviews_rg_agg_{{rnd}} as (
  select
    repo_group,
    count(distinct id) as value
  from
    reviews_data_{{rnd}}
  where
    repo_group is not null
  group by
    repo_group
);
create index on reviews_rg_agg_{{rnd}}(repo_group);
analyze reviews_rg_agg_{{rnd}};

create temp table reviews_all_agg_{{rnd}} as (
  select
    count(distinct id) as value
  from
    reviews_nb_{{rnd}}
);
analyze reviews_all_agg_{{rnd}};

select
  repo_group,
  name,
  value
from (
  select
    repo_group,
    'Contributors' as name,
    contributors as value
  from
    events_rg_agg_{{rnd}}
  where
    cnt_contrib > 0

  union all

  select
    'pstat,All' as repo_group,
    'Contributors' as name,
    contributors as value
  from
    events_all_agg_{{rnd}}

  union all

  select
    repo_group,
    'Contributions' as name,
    contributions as value
  from
    events_rg_agg_{{rnd}}
  where
    cnt_contrib > 0

  union all

  select
    'pstat,All' as repo_group,
    'Contributions' as name,
    contributions as value
  from
    events_all_agg_{{rnd}}

  union all

  select
    repo_group,
    'Pushes' as name,
    pushes as value
  from
    events_rg_agg_{{rnd}}
  where
    cnt_push > 0

  union all

  select
    'pstat,All' as repo_group,
    'Pushes' as name,
    pushes as value
  from
    events_all_agg_{{rnd}}

  union all

  select
    repo_group,
    'Commits' as name,
    commits as value
  from
    commits_agg_{{rnd}}
  where
    grp_level = 0
    and repo_group is not null

  union all

  select
    'pstat,All' as repo_group,
    'Commits' as name,
    commits as value
  from
    commits_agg_{{rnd}}
  where
    grp_level = 1

  union all

  select
    repo_group,
    'Code committers' as name,
    committers as value
  from
    commits_agg_{{rnd}}
  where
    grp_level = 0
    and repo_group is not null

  union all

  select
    'pstat,All' as repo_group,
    'Code committers' as name,
    committers as value
  from
    commits_agg_{{rnd}}
  where
    grp_level = 1

  union all

  select
    repo_group,
    case type
      when 'IssuesEvent' then 'Issue creators'
      when 'PullRequestEvent' then 'PR creators'
      when 'PushEvent' then 'Pushers'
      when 'PullRequestReviewCommentEvent' then 'PR review commenters'
      when 'PullRequestReviewEvent' then 'PR reviewers'
      when 'IssueCommentEvent' then 'Issue commenters'
      when 'CommitCommentEvent' then 'Commit commenters'
      when 'WatchEvent' then 'Stargazers/Watchers'
      when 'ForkEvent' then 'Forkers'
    end as name,
    value
  from
    evtype_rg_agg_{{rnd}}

  union all

  select
    'pstat,All' as repo_group,
    case type
      when 'IssuesEvent' then 'Issue creators'
      when 'PullRequestEvent' then 'PR creators'
      when 'PushEvent' then 'Pushers'
      when 'PullRequestReviewCommentEvent' then 'PR review commenters'
      when 'PullRequestReviewEvent' then 'PR reviewers'
      when 'IssueCommentEvent' then 'Issue commenters'
      when 'CommitCommentEvent' then 'Commit commenters'
      when 'WatchEvent' then 'Stargazers/Watchers'
      when 'ForkEvent' then 'Forkers'
    end as name,
    value
  from
    evtype_all_agg_{{rnd}}

  union all

  select
    repo_group,
    'Repositories' as name,
    value
  from
    repos_rg_agg_{{rnd}}

  union all

  select
    'pstat,All' as repo_group,
    'Repositories' as name,
    value
  from
    repos_all_agg_{{rnd}}

  union all

  select
    repo_group,
    'Comments' as name,
    comments as value
  from
    comments_rg_agg_{{rnd}}

  union all

  select
    'pstat,All' as repo_group,
    'Comments' as name,
    comments as value
  from
    comments_all_agg_{{rnd}}

  union all

  select
    repo_group,
    'Commenters' as name,
    commenters as value
  from
    comments_rg_agg_{{rnd}}

  union all

  select
    'pstat,All' as repo_group,
    'Commenters' as name,
    commenters as value
  from
    comments_all_agg_{{rnd}}

  union all

  select
    repo_group,
    'Issues' as name,
    issues as value
  from
    issues_rg_agg_{{rnd}}
  where
    cnt_issues > 0

  union all

  select
    'pstat,All' as repo_group,
    'Issues' as name,
    issues as value
  from
    issues_all_agg_{{rnd}}

  union all

  select
    repo_group,
    'PRs' as name,
    prs as value
  from
    issues_rg_agg_{{rnd}}
  where
    cnt_prs > 0

  union all

  select
    'pstat,All' as repo_group,
    'PRs' as name,
    prs as value
  from
    issues_all_agg_{{rnd}}

  union all

  select
    repo_group,
    'PR reviews' as name,
    value
  from
    reviews_rg_agg_{{rnd}}

  union all

  select
    'pstat,All' as repo_group,
    'PR reviews' as name,
    value
  from
    reviews_all_agg_{{rnd}}

  union all

  select
    repo_group,
    'Events' as name,
    events as value
  from
    events_rg_events_{{rnd}}

  union all

  select
    'pstat,All' as repo_group,
    'Events' as name,
    events as value
  from
    events_all_agg_{{rnd}}
) out
order by
  name asc,
  value desc,
  repo_group asc
;

