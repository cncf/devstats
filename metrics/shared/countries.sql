with trepo_groups_dist as (
  select distinct
    repo_group_name
  from
    trepo_groups
), base_events as (
  select
    e.id,
    e.actor_id,
    e.type,
    a.country_name,
    trg.repo_group_name as repo_group
  from
    gha_events e
  join
    gha_actors a
  on
    a.id = e.actor_id
  left join
    gha_repo_groups rg
  on
    rg.id = e.repo_id
    and rg.name = e.dup_repo_name
  left join
    trepo_groups_dist trg
  on
    trg.repo_group_name = rg.repo_group
  where
    (lower(a.login) {{exclude_bots}})
    and a.country_name is not null
    and a.country_name != ''
    and e.created_at >= '{{from}}'
    and e.created_at < '{{to}}'
), inn as (
  select
    'countries' as type,
    country_name,
    case
      when grouping(repo_group) = 1 then 'all'
      else repo_group
    end as repo_group,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)) filter (
      where type in (
        'IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent',
        'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent'
      )
    ))) as contributors,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (
      where type in (
        'IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent',
        'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent'
      )
    ))) as contributions,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)))) as users,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)))) as events,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)) filter (where type = 'PushEvent'))) as committers,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'PushEvent'))) as commits,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)) filter (where type = 'PullRequestEvent'))) as prcreators,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'PullRequestEvent'))) as prs,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)) filter (where type = 'IssuesEvent'))) as issuecreators,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'IssuesEvent'))) as issues,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)) filter (
      where type in ('CommitCommentEvent', 'IssueCommentEvent')
    ))) as commenters,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (
      where type in ('CommitCommentEvent', 'IssueCommentEvent')
    ))) as comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)) filter (
      where type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent')
    ))) as reviewers,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (
      where type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent')
    ))) as reviews,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)) filter (where type = 'WatchEvent'))) as watchers,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'WatchEvent'))) as watches,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(actor_id)) filter (where type = 'ForkEvent'))) as forkers,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(id)) filter (where type = 'ForkEvent'))) as forks
  from
    base_events
  group by
    grouping sets ((country_name), (country_name, repo_group))
)
select
  concat(
    inn.type, ';', inn.country_name, '`', inn.repo_group, ';',
    'contributors,contributions,users,events,committers,commits,prcreators,prs,issuecreators,issues,commenters,comments,reviewers,reviews,watchers,watches,forkers,forks'
  ) as name,
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
  inn
where
  inn.repo_group is not null
order by
  name
;

