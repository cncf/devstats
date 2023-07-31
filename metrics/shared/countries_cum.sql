select
  concat(inn.type, ';', inn.country_name, '`', inn.repo_group, ';contributors,contributions,users,events,committers,commits,prcreators,prs,issuecreators,issues,commenters,comments,reviewers,reviews,watchers,watches,forkers,forks') as name,
  inn.contributors,
  inn.contributions,
  inn.users,
  inn.events,
  inn.committers,
  inn.commits,
  inn.prcreators,
  inn.prs,
  inn.issuecreators,
  inn.issues,
  inn.commenters,
  inn.comments,
  inn.reviewers,
  inn.reviews,
  inn.watchers,
  inn.watches,
  inn.forkers,
  inn.forks
from (
  select 'countriescum' as type,
    a.country_name,
    'all' as repo_group,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent') when true then e.actor_id end)))) as contributors,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent') when true then e.id end)))) as contributions,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.actor_id)))) as users,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) as events,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'PushEvent' when true then e.actor_id end)))) as committers,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'PushEvent' when true then e.id end)))) as commits,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'PullRequestEvent' when true then e.actor_id end)))) as prcreators,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'PullRequestEvent' when true then e.id end)))) as prs,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'IssuesEvent' when true then e.actor_id end)))) as issuecreators,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'IssuesEvent' when true then e.id end)))) as issues,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type in ('CommitCommentEvent', 'IssueCommentEvent') when true then e.actor_id end)))) as commenters,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type in ('CommitCommentEvent', 'IssueCommentEvent') when true then e.id end)))) as comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent') when true then e.actor_id end)))) as reviewers,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent') when true then e.id end)))) as reviews,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'WatchEvent' when true then e.actor_id end)))) as watchers,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'WatchEvent' when true then e.id end)))) as watches,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'ForkEvent' when true then e.actor_id end)))) as forkers,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'ForkEvent' when true then e.id end)))) as forks
  from
    gha_events e,
    gha_actors a
  where
    (lower(a.login) {{exclude_bots}})
    and a.id = e.actor_id
    and a.country_name is not null
    and a.country_name != ''
    and e.created_at < '{{to}}'
  group by
    a.country_name
  union select 'countriescum' as type,
    a.country_name,
    r.repo_group as repo_group,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent') when true then e.actor_id end)))) as contributors,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent') when true then e.id end)))) as contributions,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.actor_id)))) as users,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) as events,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'PushEvent' when true then e.actor_id end)))) as committers,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'PushEvent' when true then e.id end)))) as commits,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'PullRequestEvent' when true then e.actor_id end)))) as prcreators,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'PullRequestEvent' when true then e.id end)))) as prs,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'IssuesEvent' when true then e.actor_id end)))) as issuecreators,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'IssuesEvent' when true then e.id end)))) as issues,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type in ('CommitCommentEvent', 'IssueCommentEvent') when true then e.actor_id end)))) as commenters,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type in ('CommitCommentEvent', 'IssueCommentEvent') when true then e.id end)))) as comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent') when true then e.actor_id end)))) as reviewers,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent') when true then e.id end)))) as reviews,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'WatchEvent' when true then e.actor_id end)))) as watchers,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'WatchEvent' when true then e.id end)))) as watches,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'ForkEvent' when true then e.actor_id end)))) as forkers,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case e.type = 'ForkEvent' when true then e.id end)))) as forks
  from
    gha_repos r,
    gha_actors a,
    gha_events e
  where
    r.id = e.repo_id
    and r.name = e.dup_repo_name
    and (lower(a.login) {{exclude_bots}})
    and a.id = e.actor_id
    and a.country_name is not null
    and a.country_name != ''
    and e.created_at < '{{to}}'
  group by
    a.country_name,
    r.repo_group
) inn
where
  inn.repo_group is not null 
order by
  name
;
