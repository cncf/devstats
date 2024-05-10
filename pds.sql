select 'hdev_' || sub.metric || ',' || sub.repo_group || '_All' as metric,
  sub.author || '$$$' || sub.company as name,
  sub.value as value
from (
  select 'contributions' as metric,
    sub.repo_group,
    sub.author,
    sub.company,
    count(distinct sub.id) as value
  from (
    select r.repo_group as repo_group,
      lower(e.dup_actor_login) as author,
      coalesce(aa.company_name, '') as company,
      e.id
    from
      gha_repo_groups r,
      gha_events e
    left join
      gha_actors_affiliations aa
    on
      aa.actor_id = e.actor_id
      and aa.dt_from <= e.created_at
      and aa.dt_to > e.created_at
    where
      r.name = e.dup_repo_name
      and r.id = e.repo_id
      and e.type in (
        'PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent',
        'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
      )
      and (lower(e.dup_actor_login) = 'wgy035')
  ) sub
  where
    sub.repo_group is not null
  group by
    sub.repo_group,
    sub.author,
    sub.company
) sub
order by
  metric asc,
  value desc,
  name asc
;
