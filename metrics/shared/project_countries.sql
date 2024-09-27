with data as (
  select 'prjcntr' as type,
    a.country_name,
    r.repo_group as repo_group,
    hll_add_agg(hll_hash_bigint(case e.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent') when true then e.actor_id end)) as contributors,
    hll_add_agg(hll_hash_bigint(case e.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent') when true then e.id end)) as contributions,
    hll_add_agg(hll_hash_bigint(e.actor_id)) as users,
    hll_add_agg(hll_hash_bigint(e.id)) as events,
    hll_add_agg(hll_hash_bigint(case e.type = 'PushEvent' when true then e.actor_id end)) as committers,
    hll_add_agg(hll_hash_bigint(case e.type = 'PushEvent' when true then e.id end)) as commits,
    hll_add_agg(hll_hash_bigint(case e.type = 'PullRequestEvent' when true then e.actor_id end)) as prcreators,
    hll_add_agg(hll_hash_bigint(case e.type = 'PullRequestEvent' when true then e.id end)) as prs,
    hll_add_agg(hll_hash_bigint(case e.type = 'IssuesEvent' when true then e.actor_id end)) as issuecreators,
    hll_add_agg(hll_hash_bigint(case e.type = 'IssuesEvent' when true then e.id end)) as issues,
    hll_add_agg(hll_hash_bigint(case e.type in ('CommitCommentEvent', 'IssueCommentEvent') when true then e.actor_id end)) as commenters,
    hll_add_agg(hll_hash_bigint(case e.type in ('CommitCommentEvent', 'IssueCommentEvent') when true then e.id end)) as comments,
    hll_add_agg(hll_hash_bigint(case e.type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent') when true then e.actor_id end)) as reviewers,
    hll_add_agg(hll_hash_bigint(case e.type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent') when true then e.id end)) as reviews,
    hll_add_agg(hll_hash_bigint(case e.type = 'WatchEvent' when true then e.actor_id end)) as watchers,
    hll_add_agg(hll_hash_bigint(case e.type = 'WatchEvent' when true then e.id end)) as watches,
    hll_add_agg(hll_hash_bigint(case e.type = 'ForkEvent' when true then e.actor_id end)) as forkers,
    hll_add_agg(hll_hash_bigint(case e.type = 'ForkEvent' when true then e.id end)) as forks
  from
    gha_repo_groups r,
    gha_actors a,
    gha_events e
  where
    r.id = e.repo_id
    and r.name = e.dup_repo_name
    and (lower(a.login) {{exclude_bots}})
    and a.id = e.actor_id
    and a.country_name is not null
    and a.country_name != ''
    and e.created_at >= '{{from}}'
    and e.created_at < '{{to}}'
  group by
    a.country_name,
    r.repo_group
)
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
from
  data inn
where
  inn.repo_group is not null 
;
