create temp table actors_country_{{rnd}} as
select
  id as actor_id,
  country_name
from
  gha_actors
where
  country_name is not null
  and country_name != ''
  and (lower(login) {{exclude_bots}})
;
create index on actors_country_{{rnd}}(actor_id);
analyze actors_country_{{rnd}};

create temp table repo_groups_{{rnd}} as
select
  id as repo_id,
  name as repo_name,
  repo_group
from
  gha_repo_groups
where
  repo_group is not null
  and repo_group in (select repo_group_name from trepo_groups)
;
create index on repo_groups_{{rnd}}(repo_id, repo_name);
analyze repo_groups_{{rnd}};

create temp table base_events_{{rnd}} as
select
  e.id,
  a.country_name,
  rg.repo_group,
  hll_hash_bigint(e.actor_id) as h_actor,
  hll_hash_bigint(e.id) as h_id,
  (e.type in (
    'IssuesEvent','PullRequestEvent','PushEvent','CommitCommentEvent',
    'IssueCommentEvent','PullRequestReviewCommentEvent','PullRequestReviewEvent'
  )) as is_contrib,
  (e.type = 'PushEvent') as is_push,
  (e.type = 'PullRequestEvent') as is_pr,
  (e.type = 'IssuesEvent') as is_issue,
  (e.type in ('CommitCommentEvent','IssueCommentEvent')) as is_comment,
  (e.type in ('PullRequestReviewCommentEvent','PullRequestReviewEvent')) as is_review,
  (e.type = 'WatchEvent') as is_watch,
  (e.type = 'ForkEvent') as is_fork
from
  gha_events e
join
  actors_country_{{rnd}} a
on
  a.actor_id = e.actor_id
left join
  repo_groups_{{rnd}} rg
on
  rg.repo_id = e.repo_id
  and rg.repo_name = e.dup_repo_name
where
  e.created_at >= '{{from}}'
  and e.created_at < '{{to}}'
;
analyze base_events_{{rnd}};

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
from (
  select
    'countries' as type,
    country_name,
    'all' as repo_group,
    round(hll_cardinality(hll_add_agg(h_actor) filter (where is_contrib))) as contributors,
    round(hll_cardinality(hll_add_agg(h_id) filter (where is_contrib))) as contributions,
    round(hll_cardinality(hll_add_agg(h_actor))) as users,
    round(hll_cardinality(hll_add_agg(h_id))) as events,
    round(hll_cardinality(hll_add_agg(h_actor) filter (where is_push))) as committers,
    round(hll_cardinality(hll_add_agg(h_id) filter (where is_push))) as commits,
    round(hll_cardinality(hll_add_agg(h_actor) filter (where is_pr))) as prcreators,
    round(hll_cardinality(hll_add_agg(h_id) filter (where is_pr))) as prs,
    round(hll_cardinality(hll_add_agg(h_actor) filter (where is_issue))) as issuecreators,
    round(hll_cardinality(hll_add_agg(h_id) filter (where is_issue))) as issues,
    round(hll_cardinality(hll_add_agg(h_actor) filter (where is_comment))) as commenters,
    round(hll_cardinality(hll_add_agg(h_id) filter (where is_comment))) as comments,
    round(hll_cardinality(hll_add_agg(h_actor) filter (where is_review))) as reviewers,
    round(hll_cardinality(hll_add_agg(h_id) filter (where is_review))) as reviews,
    round(hll_cardinality(hll_add_agg(h_actor) filter (where is_watch))) as watchers,
    round(hll_cardinality(hll_add_agg(h_id) filter (where is_watch))) as watches,
    round(hll_cardinality(hll_add_agg(h_actor) filter (where is_fork))) as forkers,
    round(hll_cardinality(hll_add_agg(h_id) filter (where is_fork))) as forks
  from
    base_events_{{rnd}}
  group by
    country_name

  union all

  select
    'countries' as type,
    country_name,
    repo_group,
    round(hll_cardinality(hll_add_agg(h_actor) filter (where is_contrib))) as contributors,
    round(hll_cardinality(hll_add_agg(h_id) filter (where is_contrib))) as contributions,
    round(hll_cardinality(hll_add_agg(h_actor))) as users,
    round(hll_cardinality(hll_add_agg(h_id))) as events,
    round(hll_cardinality(hll_add_agg(h_actor) filter (where is_push))) as committers,
    round(hll_cardinality(hll_add_agg(h_id) filter (where is_push))) as commits,
    round(hll_cardinality(hll_add_agg(h_actor) filter (where is_pr))) as prcreators,
    round(hll_cardinality(hll_add_agg(h_id) filter (where is_pr))) as prs,
    round(hll_cardinality(hll_add_agg(h_actor) filter (where is_issue))) as issuecreators,
    round(hll_cardinality(hll_add_agg(h_id) filter (where is_issue))) as issues,
    round(hll_cardinality(hll_add_agg(h_actor) filter (where is_comment))) as commenters,
    round(hll_cardinality(hll_add_agg(h_id) filter (where is_comment))) as comments,
    round(hll_cardinality(hll_add_agg(h_actor) filter (where is_review))) as reviewers,
    round(hll_cardinality(hll_add_agg(h_id) filter (where is_review))) as reviews,
    round(hll_cardinality(hll_add_agg(h_actor) filter (where is_watch))) as watchers,
    round(hll_cardinality(hll_add_agg(h_id) filter (where is_watch))) as watches,
    round(hll_cardinality(hll_add_agg(h_actor) filter (where is_fork))) as forkers,
    round(hll_cardinality(hll_add_agg(h_id) filter (where is_fork))) as forks
  from
    base_events_{{rnd}}
  where
    repo_group is not null
  group by
    country_name,
    repo_group
) inn
where
  inn.repo_group is not null
order by
  name
;

