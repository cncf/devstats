create temp table repo_groups_all_{{rnd}} as
select
  id as repo_id,
  name as repo_name,
  repo_group
from
  gha_repo_groups
;
create index on repo_groups_all_{{rnd}}(repo_id, repo_name);
analyze repo_groups_all_{{rnd}};

create temp table repo_groups_nonnull_{{rnd}} as
select
  repo_id,
  repo_name,
  repo_group
from
  repo_groups_all_{{rnd}}
where
  repo_group is not null
;
create index on repo_groups_nonnull_{{rnd}}(repo_id, repo_name);
create index on repo_groups_nonnull_{{rnd}}(repo_group);
analyze repo_groups_nonnull_{{rnd}};

create temp table events_nb_{{rnd}} as
select
  id,
  repo_id,
  dup_repo_name,
  type,
  actor_id,
  dup_actor_login
from
  gha_events
where
  {{period:created_at}}
  and (lower(dup_actor_login) {{exclude_bots}})
;
create index on events_nb_{{rnd}}(repo_id, dup_repo_name);
create index on events_nb_{{rnd}}(type);
analyze events_nb_{{rnd}};

create temp table events_nb_rg_{{rnd}} as
select
  rg.repo_group,
  e.id,
  e.type,
  e.actor_id,
  e.dup_actor_login
from
  events_nb_{{rnd}} e
join
  repo_groups_nonnull_{{rnd}} rg
on
  e.repo_id = rg.repo_id
  and e.dup_repo_name = rg.repo_name
;
create index on events_nb_rg_{{rnd}}(repo_group);
create index on events_nb_rg_{{rnd}}(type);
analyze events_nb_rg_{{rnd}};

create temp table events_all_{{rnd}} as
select
  id,
  repo_id,
  dup_repo_name
from
  gha_events
where
  {{period:created_at}}
;
create index on events_all_{{rnd}}(repo_id, dup_repo_name);
analyze events_all_{{rnd}};

create temp table events_all_rg_{{rnd}} as
select
  rg.repo_group,
  e.repo_id
from
  events_all_{{rnd}} e
join
  repo_groups_nonnull_{{rnd}} rg
on
  e.repo_id = rg.repo_id
  and e.dup_repo_name = rg.repo_name
;
create index on events_all_rg_{{rnd}}(repo_group);
analyze events_all_rg_{{rnd}};

create temp table commits_p_{{rnd}} as
select
  sha,
  dup_repo_id,
  dup_repo_name,
  dup_actor_id,
  dup_actor_login,
  author_id,
  dup_author_login,
  committer_id,
  dup_committer_login
from
  gha_commits
where
  {{period:dup_created_at}}
;
create index on commits_p_{{rnd}}(dup_repo_id, dup_repo_name);
analyze commits_p_{{rnd}};

create temp table commits_data_{{rnd}} as
select
  rg.repo_group,
  c.sha,
  v.actor_id
from
  commits_p_{{rnd}} c
join
  repo_groups_all_{{rnd}} rg
on
  c.dup_repo_id = rg.repo_id
  and c.dup_repo_name = rg.repo_name
cross join lateral (
  values
    ('dup', c.dup_actor_id, c.dup_actor_login),
    ('author', c.author_id, c.dup_author_login),
    ('committer', c.committer_id, c.dup_committer_login)
) v(role, actor_id, actor_login)
where
  (v.role = 'dup' or v.actor_id is not null)
  and (lower(v.actor_login) {{exclude_bots}})
;
create index on commits_data_{{rnd}}(repo_group);
analyze commits_data_{{rnd}};

create temp table comments_nb_{{rnd}} as
select
  id,
  dup_repo_id,
  dup_repo_name,
  user_id
from
  gha_comments
where
  {{period:created_at}}
  and (lower(dup_user_login) {{exclude_bots}})
;
create index on comments_nb_{{rnd}}(dup_repo_id, dup_repo_name);
analyze comments_nb_{{rnd}};

create temp table issues_nb_{{rnd}} as
select
  id,
  dup_repo_id,
  dup_repo_name,
  user_id,
  is_pull_request
from
  gha_issues
where
  {{period:created_at}}
  and (lower(dup_user_login) {{exclude_bots}})
;
create index on issues_nb_{{rnd}}(dup_repo_id, dup_repo_name);
analyze issues_nb_{{rnd}};

create temp table pr_reviews_nb_{{rnd}} as
select
  id,
  dup_repo_id,
  dup_repo_name
from
  gha_reviews
where
  {{period:submitted_at}}
  and (lower(dup_user_login) {{exclude_bots}})
;
create index on pr_reviews_nb_{{rnd}}(dup_repo_id, dup_repo_name);
analyze pr_reviews_nb_{{rnd}};

create temp table country_actor_ids_{{rnd}} as
select distinct
  actor_id
from
  events_nb_{{rnd}}
where
  actor_id is not null
  and type in (
    'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
    'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
  )
union
select distinct
  author_id as actor_id
from
  commits_p_{{rnd}}
where
  author_id is not null
  and (lower(dup_author_login) {{exclude_bots}})
union
select distinct
  committer_id as actor_id
from
  commits_p_{{rnd}}
where
  committer_id is not null
  and (lower(dup_committer_login) {{exclude_bots}})
;
create index on country_actor_ids_{{rnd}}(actor_id);
analyze country_actor_ids_{{rnd}};

create temp table actors_country_{{rnd}} as
select
  id as actor_id,
  country_id
from
  gha_actors
where
  id in (select actor_id from country_actor_ids_{{rnd}})
;
create index on actors_country_{{rnd}}(actor_id);
analyze actors_country_{{rnd}};

create temp table countries_all_agg_{{rnd}} as
select
  round(hll_cardinality(hll_add_agg(hll_hash_text(country_id)))) as value
from (
  select
    a.country_id
  from
    events_nb_{{rnd}} e
  join
    actors_country_{{rnd}} a
  on
    a.actor_id = e.actor_id
  where
    e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  union all
  select
    a.country_id
  from
    commits_p_{{rnd}} c
  join
    actors_country_{{rnd}} a
  on
    a.actor_id = c.author_id
  where
    c.author_id is not null
    and (lower(c.dup_author_login) {{exclude_bots}})
  union all
  select
    a.country_id
  from
    commits_p_{{rnd}} c
  join
    actors_country_{{rnd}} a
  on
    a.actor_id = c.committer_id
  where
    c.committer_id is not null
    and (lower(c.dup_committer_login) {{exclude_bots}})
) s
;
analyze countries_all_agg_{{rnd}};

create temp table countries_rg_agg_{{rnd}} as
select
  repo_group,
  round(hll_cardinality(hll_add_agg(hll_hash_text(country_id)))) as value
from (
  select
    rg.repo_group,
    a.country_id
  from
    events_nb_{{rnd}} e
  join
    repo_groups_nonnull_{{rnd}} rg
  on
    e.repo_id = rg.repo_id
    and e.dup_repo_name = rg.repo_name
  join
    actors_country_{{rnd}} a
  on
    a.actor_id = e.actor_id
  where
    e.type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  union all
  select
    rg.repo_group,
    a.country_id
  from
    commits_p_{{rnd}} c
  join
    repo_groups_nonnull_{{rnd}} rg
  on
    c.dup_repo_id = rg.repo_id
    and c.dup_repo_name = rg.repo_name
  join
    actors_country_{{rnd}} a
  on
    a.actor_id = c.author_id
  where
    c.author_id is not null
    and (lower(c.dup_author_login) {{exclude_bots}})
  union all
  select
    rg.repo_group,
    a.country_id
  from
    commits_p_{{rnd}} c
  join
    repo_groups_nonnull_{{rnd}} rg
  on
    c.dup_repo_id = rg.repo_id
    and c.dup_repo_name = rg.repo_name
  join
    actors_country_{{rnd}} a
  on
    a.actor_id = c.committer_id
  where
    c.committer_id is not null
    and (lower(c.dup_committer_login) {{exclude_bots}})
) s
group by
  repo_group
;
create index on countries_rg_agg_{{rnd}}(repo_group);
analyze countries_rg_agg_{{rnd}};

create temp table events_all_agg_{{rnd}} as
select
  round(hll_cardinality(hll_add_agg(hll_hash_text(dup_actor_login)) filter (
    where type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  ))) as contributors,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (
    where type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  ))) as contributions,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'PushEvent'))) as pushes,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as events
from
  events_nb_{{rnd}}
;
analyze events_all_agg_{{rnd}};

create temp table events_rg_agg_{{rnd}} as
select
  repo_group,
  count(*) as cnt_all,
  count(*) filter (
    where type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  ) as cnt_contrib,
  count(*) filter (where type = 'PushEvent') as cnt_push,
  round(hll_cardinality(hll_add_agg(hll_hash_text(dup_actor_login)) filter (
    where type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  ))) as contributors,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (
    where type in (
      'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
      'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    )
  ))) as contributions,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'PushEvent'))) as pushes,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as events
from
  events_nb_rg_{{rnd}}
group by
  repo_group
;
create index on events_rg_agg_{{rnd}}(repo_group);
analyze events_rg_agg_{{rnd}};

create temp table evtype_all_agg_{{rnd}} as
select
  type,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)))) as value
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
;
analyze evtype_all_agg_{{rnd}};

create temp table evtype_rg_agg_{{rnd}} as
select
  repo_group,
  type,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)))) as value
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
;
create index on evtype_rg_agg_{{rnd}}(repo_group, type);
analyze evtype_rg_agg_{{rnd}};

create temp table repos_all_agg_{{rnd}} as
select
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(repo_id)))) as value
from
  events_all_{{rnd}}
;
analyze repos_all_agg_{{rnd}};

create temp table repos_rg_agg_{{rnd}} as
select
  repo_group,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(repo_id)))) as value
from
  events_all_rg_{{rnd}}
group by
  repo_group
;
create index on repos_rg_agg_{{rnd}}(repo_group);
analyze repos_rg_agg_{{rnd}};

create temp table commits_agg_{{rnd}} as
select
  repo_group,
  grouping(repo_group) as grp_level,
  round(hll_cardinality(hll_add_agg(hll_hash_text(sha)))) as commits,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)))) as committers
from
  commits_data_{{rnd}}
group by
  grouping sets ((repo_group), ())
;
create index on commits_agg_{{rnd}}(grp_level, repo_group);
analyze commits_agg_{{rnd}};

create temp table comments_all_agg_{{rnd}} as
select
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as comments,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(user_id)))) as commenters
from
  comments_nb_{{rnd}}
;
analyze comments_all_agg_{{rnd}};

create temp table comments_rg_agg_{{rnd}} as
select
  rg.repo_group,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(c.id)))) as comments,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(c.user_id)))) as commenters
from
  comments_nb_{{rnd}} c
join
  repo_groups_nonnull_{{rnd}} rg
on
  c.dup_repo_id = rg.repo_id
  and c.dup_repo_name = rg.repo_name
group by
  rg.repo_group
;
create index on comments_rg_agg_{{rnd}}(repo_group);
analyze comments_rg_agg_{{rnd}};

create temp table prreviews_all_agg_{{rnd}} as
select
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as value
from
  pr_reviews_nb_{{rnd}}
;
analyze prreviews_all_agg_{{rnd}};

create temp table prreviews_rg_agg_{{rnd}} as
select
  rg.repo_group,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(rv.id)))) as value
from
  pr_reviews_nb_{{rnd}} rv
join
  repo_groups_nonnull_{{rnd}} rg
on
  rv.dup_repo_id = rg.repo_id
  and rv.dup_repo_name = rg.repo_name
group by
  rg.repo_group
;
create index on prreviews_rg_agg_{{rnd}}(repo_group);
analyze prreviews_rg_agg_{{rnd}};

create temp table issues_all_agg_{{rnd}} as
select
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where is_pull_request = false))) as issues,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where is_pull_request = true))) as prs
from
  issues_nb_{{rnd}}
;
analyze issues_all_agg_{{rnd}};

create temp table issues_rg_agg_{{rnd}} as
select
  rg.repo_group,
  count(*) filter (where i.is_pull_request = false) as cnt_issues,
  count(*) filter (where i.is_pull_request = true) as cnt_prs,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)) filter (where i.is_pull_request = false))) as issues,
  round(hll_cardinality(hll_add_agg(hll_hash_bigint(i.id)) filter (where i.is_pull_request = true))) as prs
from
  issues_nb_{{rnd}} i
join
  repo_groups_nonnull_{{rnd}} rg
on
  i.dup_repo_id = rg.repo_id
  and i.dup_repo_name = rg.repo_name
group by
  rg.repo_group
;
create index on issues_rg_agg_{{rnd}}(repo_group);
analyze issues_rg_agg_{{rnd}};

select
  repo_group,
  name,
  value
from (
  select
    'pstat,All' as repo_group,
    'Projects/Repository groups' as name,
    round(hll_cardinality(hll_add_agg(hll_hash_text(repo_group)))) as value
  from
    repo_groups_nonnull_{{rnd}}

  union

  select
    'pstat,All' as repo_group,
    'Countries' as name,
    value
  from
    countries_all_agg_{{rnd}}

  union

  select
    'pstat,' || repo_group as repo_group,
    'Countries' as name,
    value
  from
    countries_rg_agg_{{rnd}}

  union

  select
    'pstat,All' as repo_group,
    'Contributors' as name,
    contributors as value
  from
    events_all_agg_{{rnd}}

  union

  select
    'pstat,' || repo_group as repo_group,
    'Contributors' as name,
    contributors as value
  from
    events_rg_agg_{{rnd}}
  where
    cnt_contrib > 0

  union

  select
    'pstat,All' as repo_group,
    'Contributions' as name,
    contributions as value
  from
    events_all_agg_{{rnd}}

  union

  select
    'pstat,' || repo_group as repo_group,
    'Contributions' as name,
    contributions as value
  from
    events_rg_agg_{{rnd}}
  where
    cnt_contrib > 0

  union

  select
    'pstat,All' as repo_group,
    'Pushes' as name,
    pushes as value
  from
    events_all_agg_{{rnd}}

  union

  select
    'pstat,' || repo_group as repo_group,
    'Pushes' as name,
    pushes as value
  from
    events_rg_agg_{{rnd}}
  where
    cnt_push > 0

  union

  select
    'pstat,All' as repo_group,
    'Commits' as name,
    commits as value
  from
    commits_agg_{{rnd}}
  where
    grp_level = 1

  union

  select
    'pstat,' || repo_group as repo_group,
    'Commits' as name,
    commits as value
  from
    commits_agg_{{rnd}}
  where
    grp_level = 0
    and repo_group is not null

  union

  select
    'pstat,All' as repo_group,
    'Code committers' as name,
    committers as value
  from
    commits_agg_{{rnd}}
  where
    grp_level = 1

  union

  select
    'pstat,' || repo_group as repo_group,
    'Code committers' as name,
    committers as value
  from
    commits_agg_{{rnd}}
  where
    grp_level = 0
    and repo_group is not null

  union

  select
    'pstat,' || repo_group as repo_group,
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

  union

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

  union

  select
    'pstat,' || repo_group as repo_group,
    'Repositories' as name,
    value
  from
    repos_rg_agg_{{rnd}}

  union

  select
    'pstat,All' as repo_group,
    'Repositories' as name,
    value
  from
    repos_all_agg_{{rnd}}

  union

  select
    'pstat,' || repo_group as repo_group,
    'Comments' as name,
    comments as value
  from
    comments_rg_agg_{{rnd}}

  union

  select
    'pstat,All' as repo_group,
    'Comments' as name,
    comments as value
  from
    comments_all_agg_{{rnd}}

  union

  select
    'pstat,' || repo_group as repo_group,
    'Commenters' as name,
    commenters as value
  from
    comments_rg_agg_{{rnd}}

  union

  select
    'pstat,All' as repo_group,
    'Commenters' as name,
    commenters as value
  from
    comments_all_agg_{{rnd}}

  union

  select
    'pstat,' || repo_group as repo_group,
    'PR reviews' as name,
    value
  from
    prreviews_rg_agg_{{rnd}}

  union

  select
    'pstat,All' as repo_group,
    'PR reviews' as name,
    value
  from
    prreviews_all_agg_{{rnd}}

  union

  select
    'pstat,' || repo_group as repo_group,
    'Issues' as name,
    issues as value
  from
    issues_rg_agg_{{rnd}}
  where
    cnt_issues > 0

  union

  select
    'pstat,All' as repo_group,
    'Issues' as name,
    issues as value
  from
    issues_all_agg_{{rnd}}

  union

  select
    'pstat,' || repo_group as repo_group,
    'PRs' as name,
    prs as value
  from
    issues_rg_agg_{{rnd}}
  where
    cnt_prs > 0

  union

  select
    'pstat,All' as repo_group,
    'PRs' as name,
    prs as value
  from
    issues_all_agg_{{rnd}}

  union

  select
    'pstat,' || repo_group as repo_group,
    'Events' as name,
    events as value
  from
    events_rg_agg_{{rnd}}
  where
    cnt_all > 0

  union

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

