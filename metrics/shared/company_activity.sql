create temp table ca_events_{{rnd}} as
select
  ev.id,
  ev.type,
  ev.actor_id,
  ev.repo_id,
  ev.dup_repo_name as repo_name,
  ev.created_at
from
  gha_events ev
where
  ev.created_at >= '{{from}}'
  and ev.created_at < '{{to}}'
  and (lower(ev.dup_actor_login) {{exclude_bots}})
;
analyze ca_events_{{rnd}};

create temp table ca_company_events_{{rnd}} as
select
  affs.company_name as company,
  ev.id,
  ev.type,
  ev.actor_id,
  ev.repo_id,
  ev.repo_name
from
  ca_events_{{rnd}} ev,
  gha_actors_affiliations affs
where
  ev.actor_id = affs.actor_id
  and affs.dt_from <= ev.created_at
  and affs.dt_to > ev.created_at
  and affs.company_name in (select companies_name from tcompanies)
  and affs.company_name != ''
;
analyze ca_company_events_{{rnd}};

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
  select ev.company,
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
    ca_company_events_{{rnd}} ev
  group by
    ev.company
  union select ev.company,
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
    ca_company_events_{{rnd}} ev,
    gha_repo_groups r
  where
    r.id = ev.repo_id
    and r.name = ev.repo_name
    and r.repo_group in (select repo_group_name from trepo_groups)
  group by
    ev.company,
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
    ca_events_{{rnd}} ev
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
    ca_events_{{rnd}} ev,
    gha_repo_groups r
  where
    r.id = ev.repo_id
    and r.name = ev.repo_name
    and r.repo_group in (select repo_group_name from trepo_groups)
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
