create temp table cak_events_{{rnd}} as
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
analyze cak_events_{{rnd}};

create temp table cak_company_events_{{rnd}} as
select
  affs.company_name as company,
  ev.id,
  ev.type,
  ev.actor_id,
  ev.repo_id,
  ev.repo_name
from
  cak_events_{{rnd}} ev,
  gha_actors_affiliations affs
where
  ev.actor_id = affs.actor_id
  and affs.dt_from <= ev.created_at
  and affs.dt_to > ev.created_at
  and affs.company_name in (select companies_name from tcompanies)
  and affs.company_name != ''
;
analyze cak_company_events_{{rnd}};

select
  concat('company;', sub.company, '`', sub.repo_group, ';activity,authors,issues,prs,pushers,pushes,reviews,comments,contributions,contributors'),
  round(sub.activity / {{n}}, 2) as activity,
  sub.authors,
  round(sub.issues / {{n}}, 2) as issues,
  round(sub.prs / {{n}}, 2) as prs,
  sub.pushers,
  round(sub.pushes / {{n}}, 2) as pushes,
  round(sub.reviews / {{n}}, 2) as reviews,
  round((sub.review_comments + sub.issue_comments + sub.commit_comments) / {{n}}, 2) as comments,
  round((sub.review_comments + sub.issue_comments + sub.commit_comments + sub.pushes + sub.reviews + sub.issues + sub.prs) / {{n}}, 2) as contributions,
  sub.contributors
from (
  select ev.company,
    'all' as repo_group,
    count(distinct ev.id) as activity,
    count(distinct ev.actor_id) as authors,
    count(distinct ev.actor_id) filter(where ev.type = 'PushEvent') as pushers,
    count(distinct ev.actor_id) filter (where ev.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent')) as contributors,
    count(distinct ev.id) filter(where ev.type = 'IssuesEvent') as issues,
    count(distinct ev.id) filter(where ev.type = 'PullRequestEvent') as prs,
    count(distinct ev.id) filter(where ev.type = 'PushEvent') as pushes,
    count(distinct ev.id) filter(where ev.type = 'PullRequestReviewCommentEvent') as review_comments,
    count(distinct ev.id) filter(where ev.type = 'PullRequestReviewEvent') as reviews,
    count(distinct ev.id) filter(where ev.type = 'IssueCommentEvent') as issue_comments,
    count(distinct ev.id) filter(where ev.type = 'CommitCommentEvent') as commit_comments
  from
    cak_company_events_{{rnd}} ev
  group by
    ev.company
  union select ev.company,
    coalesce(ecf.repo_group, r.repo_group) as repo_group,
    count(distinct ev.id) as activity,
    count(distinct ev.actor_id) as authors,
    count(distinct ev.actor_id) filter(where ev.type = 'PushEvent') as pushers,
    count(distinct ev.actor_id) filter (where ev.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent')) as contributors,
    count(distinct ev.id) filter(where ev.type = 'IssuesEvent') as issues,
    count(distinct ev.id) filter(where ev.type = 'PullRequestEvent') as prs,
    count(distinct ev.id) filter(where ev.type = 'PushEvent') as pushes,
    count(distinct ev.id) filter(where ev.type = 'PullRequestReviewCommentEvent') as review_comments,
    count(distinct ev.id) filter(where ev.type = 'PullRequestReviewEvent') as reviews,
    count(distinct ev.id) filter(where ev.type = 'IssueCommentEvent') as issue_comments,
    count(distinct ev.id) filter(where ev.type = 'CommitCommentEvent') as commit_comments
  from
    gha_repos r,
    cak_company_events_{{rnd}} ev
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = ev.id
  where
    r.id = ev.repo_id
    and r.name = ev.repo_name
    and r.repo_group in (select repo_group_name from trepo_groups)
  group by
    ev.company,
    coalesce(ecf.repo_group, r.repo_group)
  union select 'All' as company,
    'all' as repo_group,
    count(distinct ev.id) as activity,
    count(distinct ev.actor_id) as authors,
    count(distinct ev.actor_id) filter(where ev.type = 'PushEvent') as pushers,
    count(distinct ev.actor_id) filter (where ev.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent')) as contributors,
    count(distinct ev.id) filter(where ev.type = 'IssuesEvent') as issues,
    count(distinct ev.id) filter(where ev.type = 'PullRequestEvent') as prs,
    count(distinct ev.id) filter(where ev.type = 'PushEvent') as pushes,
    count(distinct ev.id) filter(where ev.type = 'PullRequestReviewCommentEvent') as review_comments,
    count(distinct ev.id) filter(where ev.type = 'PullRequestReviewEvent') as reviews,
    count(distinct ev.id) filter(where ev.type = 'IssueCommentEvent') as issue_comments,
    count(distinct ev.id) filter(where ev.type = 'CommitCommentEvent') as commit_comments
  from
    cak_events_{{rnd}} ev
  union select 'All' as company,
    coalesce(ecf.repo_group, r.repo_group) as repo_group,
    count(distinct ev.id) as activity,
    count(distinct ev.actor_id) as authors,
    count(distinct ev.actor_id) filter(where ev.type = 'PushEvent') as pushers,
    count(distinct ev.actor_id) filter (where ev.type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent')) as contributors,
    count(distinct ev.id) filter(where ev.type = 'IssuesEvent') as issues,
    count(distinct ev.id) filter(where ev.type = 'PullRequestEvent') as prs,
    count(distinct ev.id) filter(where ev.type = 'PushEvent') as pushes,
    count(distinct ev.id) filter(where ev.type = 'PullRequestReviewCommentEvent') as review_comments,
    count(distinct ev.id) filter(where ev.type = 'PullRequestReviewEvent') as reviews,
    count(distinct ev.id) filter(where ev.type = 'IssueCommentEvent') as issue_comments,
    count(distinct ev.id) filter(where ev.type = 'CommitCommentEvent') as commit_comments
  from
    gha_repos r,
    cak_events_{{rnd}} ev
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = ev.id
  where
    r.id = ev.repo_id
    and r.name = ev.repo_name
    and r.repo_group in (select repo_group_name from trepo_groups)
  group by
    coalesce(ecf.repo_group, r.repo_group)
  order by
    authors desc,
    activity desc,
    company asc
  ) sub
where
  sub.repo_group is not null
  and sub.authors > 0
;
