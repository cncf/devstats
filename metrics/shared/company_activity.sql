select
  concat('company;', sub.company, '`', sub.repo_group, ';activity,authors,issues,prs,pushers,pushes,comments,reviews,contributions,contributors'),
  round(sub.activity::numeric / {{n}}, 2) as activity,
  sub.authors,
  round(sub.issues::numeric / {{n}}, 2) as issues,
  round(sub.prs::numeric / {{n}}, 2) as prs,
  sub.pushers,
  round(sub.pushes::numeric / {{n}}, 2) as pushes,
  round((sub.review_comments + sub.issue_comments + sub.commit_comments)::numeric / {{n}}, 2) as comments,
  round(sub.reviews::numeric / {{n}}, 2) as reviews,
  round((sub.review_comments + sub.issue_comments + sub.commit_comments + sub.pushes + sub.reviews + sub.issues + sub.prs)::numeric / {{n}}, 2) as contributions,
  sub.contributors
from (
  select affs.company_name as company,
    'all' as repo_group,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(ev.id)))) as activity,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(ev.actor_id)))) as authors,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PushEvent' when true then ev.actor_id end)))) as pushers,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent') when true then ev.actor_id end)))) as contributors,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'IssuesEvent' when true then ev.id end)))) as issues,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PullRequestEvent' when true then ev.id end)))) as prs,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PushEvent' when true then ev.id end)))) as pushes,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PullRequestReviewCommentEvent' when true then ev.id end)))) as review_comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PullRequestReviewEvent' when true then ev.id end)))) as reviews,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'IssueCommentEvent' when true then ev.id end)))) as issue_comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'CommitCommentEvent' when true then ev.id end)))) as commit_comments
  from
    gha_events ev,
    gha_actors_affiliations affs
  where
    ev.actor_id = affs.actor_id
    and affs.dt_from <= ev.created_at
    and affs.dt_to > ev.created_at
    and ev.created_at >= '{{from}}'
    and ev.created_at < '{{to}}'
    and (lower(ev.dup_actor_login) {{exclude_bots}})
    and affs.company_name in (select companies_name from tcompanies)
    and affs.company_name != ''
  group by
    affs.company_name
  union select affs.company_name as company,
    r.repo_group as repo_group,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(ev.id)))) as activity,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(ev.actor_id)))) as authors,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PushEvent' when true then ev.actor_id end)))) as pushers,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent') when true then ev.actor_id end)))) as contributors,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'IssuesEvent' when true then ev.id end)))) as issues,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PullRequestEvent' when true then ev.id end)))) as prs,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PushEvent' when true then ev.id end)))) as pushes,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PullRequestReviewCommentEvent' when true then ev.id end)))) as review_comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PullRequestReviewEvent' when true then ev.id end)))) as reviews,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'IssueCommentEvent' when true then ev.id end)))) as issue_comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'CommitCommentEvent' when true then ev.id end)))) as commit_comments
  from
    gha_actors_affiliations affs,
    gha_repos r,
    gha_events ev
  where
    r.id = ev.repo_id
    and r.name = ev.dup_repo_name
    and r.name in (select repo_name from trepos)
    and ev.actor_id = affs.actor_id
    and affs.dt_from <= ev.created_at
    and affs.dt_to > ev.created_at
    and ev.created_at >= '{{from}}'
    and ev.created_at < '{{to}}'
    and (lower(ev.dup_actor_login) {{exclude_bots}})
    and affs.company_name in (select companies_name from tcompanies)
    and affs.company_name != ''
  group by
    affs.company_name,
    r.repo_group
  union select 'All' as company,
    'all' as repo_group,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(ev.id)))) as activity,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(ev.actor_id)))) as authors,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PushEvent' when true then ev.actor_id end)))) as pushers,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent') when true then ev.actor_id end)))) as contributors,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'IssuesEvent' when true then ev.id end)))) as issues,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PullRequestEvent' when true then ev.id end)))) as prs,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PushEvent' when true then ev.id end)))) as pushes,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PullRequestReviewCommentEvent' when true then ev.id end)))) as review_comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PullRequestReviewEvent' when true then ev.id end)))) as reviews,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'IssueCommentEvent' when true then ev.id end)))) as issue_comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'CommitCommentEvent' when true then ev.id end)))) as commit_comments
  from
    gha_events ev
  where
    ev.created_at >= '{{from}}'
    and ev.created_at < '{{to}}'
    and (lower(ev.dup_actor_login) {{exclude_bots}})
  union select 'All' as company,
    r.repo_group as repo_group,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(ev.id)))) as activity,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(ev.actor_id)))) as authors,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PushEvent' when true then ev.actor_id end)))) as pushers,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent') when true then ev.actor_id end)))) as contributors,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'IssuesEvent' when true then ev.id end)))) as issues,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PullRequestEvent' when true then ev.id end)))) as prs,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PushEvent' when true then ev.id end)))) as pushes,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PullRequestReviewCommentEvent' when true then ev.id end)))) as review_comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'PullRequestReviewEvent' when true then ev.id end)))) as reviews,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'IssueCommentEvent' when true then ev.id end)))) as issue_comments,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(case ev.type = 'CommitCommentEvent' when true then ev.id end)))) as commit_comments
  from
    gha_repos r,
    gha_events ev
  where
    r.id = ev.repo_id
    and r.name = ev.dup_repo_name
    and r.name in (select repo_name from trepos)
    and ev.created_at >= '{{from}}'
    and ev.created_at < '{{to}}'
    and (lower(ev.dup_actor_login) {{exclude_bots}})
  group by
    r.repo_group
  order by
    authors desc,
    activity desc,
    company asc
  ) sub
where
  sub.repo_group is not null
  and sub.authors > 0
;
