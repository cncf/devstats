-- temp_buffers must be set before the session touches any temp table,
-- calc_metric reuses sessions across ranges, so ignore the error then
do $$ begin
  begin
    set temp_buffers = '1GB';
  exception when others then
    null;
  end;
end $$;

create temp table gsr_matching_{{rnd}} as
select distinct event_id
from
  gha_texts
where
  created_at >= '{{from}}'
  and created_at < '{{to}}'
  and (body ilike '%/lgtm%' or body ilike '%/approve%')
  and substring(body from '(?i)(?:^|\n|\r)\s*/(?:lgtm|approve)\s*(?:\n|\r|$)') is not null
;
analyze gsr_matching_{{rnd}};

create temp table gsr_reviews_{{rnd}} as
select id as event_id
from
  gha_events
where
  created_at >= '{{from}}'
  and created_at < '{{to}}'
  and type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent')
;
analyze gsr_reviews_{{rnd}};

create temp table gsr_rev_ids_{{rnd}} as
select distinct event_id
from (
  select min(event_id) as event_id
  from
    gha_issues_events_labels
  where
    created_at >= '{{from}}'
    and created_at < '{{to}}'
    and label_name in ('lgtm', 'approved')
  group by
    issue_id
  union all select event_id from gsr_matching_{{rnd}}
  union all select event_id from gsr_reviews_{{rnd}}
) u
where
  event_id is not null
;
create index on gsr_rev_ids_{{rnd}}(event_id);
analyze gsr_rev_ids_{{rnd}};

create temp table gsr_ic_{{rnd}} as
select
  i.event_id,
  i.dup_actor_id,
  lower(i.dup_actor_login) as actor_login,
  i.is_pull_request,
  r.repo_group
from
  gha_issues i,
  gha_repos r
where
  i.dup_repo_id = r.id
  and i.dup_repo_name = r.name
  and r.repo_group is not null
  and i.dup_created_at >= '{{from}}'
  and i.dup_created_at < '{{to}}'
  and i.dup_type = 'IssueCommentEvent'
;
analyze gsr_ic_{{rnd}};

create temp table gsr_commits_{{rnd}} as
select distinct
  coalesce(ecf.repo_group, r.repo_group) as repo_group,
  c.sha,
  lower(c.dup_actor_login) as actor_login
from
  gha_repos r,
  gha_commits c
left join
  gha_events_commits_files ecf
on
  ecf.event_id = c.event_id
where
  r.name = c.dup_repo_name
  and r.id = c.dup_repo_id
  and c.dup_created_at >= '{{from}}'
  and c.dup_created_at < '{{to}}'
  and coalesce(ecf.repo_group, r.repo_group) is not null
;
analyze gsr_commits_{{rnd}};

create temp table gsr_rev_{{rnd}} as
select distinct
  coalesce(ecf.repo_group, r.repo_group) as repo_group,
  e.dup_actor_login as actor,
  lower(e.dup_actor_login) as actor_login
from
  gha_repos r,
  gha_events e
left join
  gha_events_commits_files ecf
on
  ecf.event_id = e.id
where
  e.repo_id = r.id
  and e.dup_repo_name = r.name
  and coalesce(ecf.repo_group, r.repo_group) is not null
  and e.id in (select event_id from gsr_rev_ids_{{rnd}})
;
analyze gsr_rev_{{rnd}};

-- evaluate the ~100 like patterns of exclude_bots once per distinct login,
-- consumers below use a cheap hashed semi-join instead of the per-row patterns
create temp table gsr_ok_logins_{{rnd}} as
select login
from (
  select distinct actor_login as login from gsr_ic_{{rnd}}
  union select distinct actor_login from gsr_commits_{{rnd}}
  union select distinct actor_login from gsr_rev_{{rnd}}
) sub
where
  login is not null
  and (login {{exclude_bots}})
;
create index on gsr_ok_logins_{{rnd}}(login);
analyze gsr_ok_logins_{{rnd}};

select
  'gstat_rgrp_commits,' || sub.repo_group as repo_group,
  round(count(distinct sub.sha) / {{n}}, 2) as metric
from
  gsr_commits_{{rnd}} sub
where
  sub.actor_login in (select login from gsr_ok_logins_{{rnd}})
group by
  sub.repo_group
union select 'gstat_rgrp_iclosed,' || r.repo_group as repo_group,
  round(count(distinct i.id) / {{n}}, 2) as metric
from
  gha_issues i,
  gha_repos r
where
  i.dup_repo_id = r.id
  and i.dup_repo_name = r.name
  and r.repo_group is not null
  and i.closed_at >= '{{from}}'
  and i.closed_at < '{{to}}'
group by
  r.repo_group
union select 'gstat_rgrp_iopened,' || r.repo_group as repo_group,
  round(count(distinct i.id) / {{n}}, 2) as metric
from
  gha_issues i,
  gha_repos r
where
  i.dup_repo_id = r.id
  and i.dup_repo_name = r.name
  and r.repo_group is not null
  and i.created_at >= '{{from}}'
  and i.created_at < '{{to}}'
group by
  r.repo_group
union select sub.repo_group,
  round(count(distinct sub.id) / {{n}}, 2) as metric
from (
    select 'gstat_rgrp_propened,' || coalesce(ecf.repo_group, r.repo_group) as repo_group,
    pr.id
  from
    gha_repos r,
    gha_pull_requests pr
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = pr.event_id
  where
    pr.dup_repo_id = r.id
    and pr.dup_repo_name = r.name
    and pr.created_at >= '{{from}}'
    and pr.created_at < '{{to}}'
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
union select sub.repo_group,
  round(count(distinct sub.id) / {{n}}, 2) as metric
from (
  select 'gstat_rgrp_prmerged,' || coalesce(ecf.repo_group, r.repo_group) as repo_group,
    pr.id
  from
    gha_repos r,
    gha_pull_requests pr
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = pr.event_id
  where
    r.name = pr.dup_repo_name
    and r.id = pr.dup_repo_id
    and pr.merged_at is not null
    and pr.merged_at >= '{{from}}'
    and pr.merged_at < '{{to}}'
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
union select sub.repo_group,
  round(count(distinct sub.id) / {{n}}, 2) as metric
from (
  select 'gstat_rgrp_prclosed,' || coalesce(ecf.repo_group, r.repo_group) as repo_group,
    pr.id
  from
    gha_repos r,
    gha_pull_requests pr
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = pr.event_id
  where
    r.name = pr.dup_repo_name
    and r.id = pr.dup_repo_id
    and pr.merged_at is null
    and pr.closed_at >= '{{from}}'
    and pr.closed_at < '{{to}}'
  ) sub
where
  sub.repo_group is not null
group by
  sub.repo_group
union select 'gstat_rgrp_prcomments,' || i.repo_group as repo_group,
  round(count(distinct i.event_id) / {{n}}, 2) as metric
from
  gsr_ic_{{rnd}} i
where
  i.is_pull_request = false
  and i.actor_login in (select login from gsr_ok_logins_{{rnd}})
group by
  i.repo_group
union select 'gstat_rgrp_prcommenters,' || i.repo_group as repo_group,
  count(distinct i.dup_actor_id) as metric
from
  gsr_ic_{{rnd}} i
where
  i.is_pull_request = false
  and i.actor_login in (select login from gsr_ok_logins_{{rnd}})
group by
  i.repo_group
union select 'gstat_rgrp_icomments,' || i.repo_group as repo_group,
  round(count(distinct i.event_id) / {{n}}, 2) as metric
from
  gsr_ic_{{rnd}} i
where
  i.is_pull_request = true
  and i.actor_login in (select login from gsr_ok_logins_{{rnd}})
group by
  i.repo_group
union select 'gstat_rgrp_icommenters,' || i.repo_group as repo_group,
  count(distinct i.dup_actor_id) as metric
from
  gsr_ic_{{rnd}} i
where
  i.is_pull_request = true
  and i.actor_login in (select login from gsr_ok_logins_{{rnd}})
group by
  i.repo_group
union select 'gstat_rgrp_reviewers,' || sub.repo_group as repo_group,
  count(distinct sub.actor) as metric
from
  gsr_rev_{{rnd}} sub
where
  sub.actor_login in (select login from gsr_ok_logins_{{rnd}})
group by
  sub.repo_group
order by
  repo_group asc
;
