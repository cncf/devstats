-- temp_buffers must be set before the session touches any temp table,
-- calc_metric reuses sessions across ranges, so ignore the error then
do $$ begin
  begin
    set temp_buffers = '1GB';
  exception when others then
    null;
  end;
end $$;

create temp table gsa_matching_{{rnd}} as
select distinct event_id
from
  gha_texts
where
  created_at >= '{{from}}'
  and created_at < '{{to}}'
  and (body ilike '%/lgtm%' or body ilike '%/approve%')
  and substring(body from '(?i)(?:^|\n|\r)\s*/(?:lgtm|approve)\s*(?:\n|\r|$)') is not null
;
analyze gsa_matching_{{rnd}};

create temp table gsa_reviews_{{rnd}} as
select id as event_id
from
  gha_events
where
  created_at >= '{{from}}'
  and created_at < '{{to}}'
  and type in ('PullRequestReviewCommentEvent', 'PullRequestReviewEvent')
;
analyze gsa_reviews_{{rnd}};

create temp table gsa_rev_ids_{{rnd}} as
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
  union all select event_id from gsa_matching_{{rnd}}
  union all select event_id from gsa_reviews_{{rnd}}
) u
where
  event_id is not null
;
create index on gsa_rev_ids_{{rnd}}(event_id);
analyze gsa_rev_ids_{{rnd}};

create temp table gsa_ic_{{rnd}} as
select
  i.event_id,
  i.dup_actor_id,
  lower(i.dup_actor_login) as actor_login,
  i.is_pull_request,
  r.alias
from
  gha_issues i,
  gha_repos r
where
  i.dup_repo_id = r.id
  and i.dup_repo_name = r.name
  and i.dup_created_at >= '{{from}}'
  and i.dup_created_at < '{{to}}'
  and i.dup_type = 'IssueCommentEvent'
  and r.alias is not null
;
analyze gsa_ic_{{rnd}};

create temp table gsa_commits_{{rnd}} as
select distinct
  r.alias,
  c.sha,
  lower(c.dup_actor_login) as actor_login
from
  gha_repos r,
  gha_commits c
where
  r.name = c.dup_repo_name
  and r.id = c.dup_repo_id
  and c.dup_created_at >= '{{from}}'
  and c.dup_created_at < '{{to}}'
  and r.alias is not null
;
analyze gsa_commits_{{rnd}};

create temp table gsa_rev_{{rnd}} as
select distinct
  r.alias,
  e.dup_actor_login as actor,
  lower(e.dup_actor_login) as actor_login
from
  gha_repos r,
  gha_events e
where
  e.repo_id = r.id
  and e.dup_repo_name = r.name
  and r.alias is not null
  and e.id in (select event_id from gsa_rev_ids_{{rnd}})
;
analyze gsa_rev_{{rnd}};

-- evaluate the ~100 like patterns of exclude_bots once per distinct login,
-- consumers below use a cheap hashed semi-join instead of the per-row patterns
create temp table gsa_ok_logins_{{rnd}} as
select login
from (
  select distinct actor_login as login from gsa_ic_{{rnd}}
  union select distinct actor_login from gsa_commits_{{rnd}}
  union select distinct actor_login from gsa_rev_{{rnd}}
) sub
where
  login is not null
  and (login {{exclude_bots}})
;
create index on gsa_ok_logins_{{rnd}}(login);
analyze gsa_ok_logins_{{rnd}};

select 'gstat_r_commits,' || c.alias as repo,
  round(count(distinct c.sha) / {{n}}, 2) as metric
from
  gsa_commits_{{rnd}} c
where
  c.actor_login in (select login from gsa_ok_logins_{{rnd}})
group by
  c.alias
union select 'gstat_r_iclosed,' || r.alias as repo,
  round(count(distinct i.id) / {{n}}, 2) as metric
from
  gha_issues i,
  gha_repos r
where
  i.dup_repo_id = r.id
  and i.dup_repo_name = r.name
  and i.closed_at >= '{{from}}'
  and i.closed_at < '{{to}}'
  and r.alias is not null
group by
  r.alias
union select 'gstat_r_iopened,' || r.alias as repo,
  round(count(distinct i.id) / {{n}}, 2) as metric
from
  gha_issues i,
  gha_repos r
where
  i.dup_repo_id = r.id
  and i.dup_repo_name = r.name
  and i.created_at >= '{{from}}'
  and i.created_at < '{{to}}'
  and r.alias is not null
group by
  r.alias
union select 'gstat_r_propened,' || r.alias as repo,
  round(count(distinct pr.id) / {{n}}, 2) as metric
from
  gha_repos r,
  gha_pull_requests pr
where
  pr.dup_repo_id = r.id
  and pr.dup_repo_name = r.name
  and pr.created_at >= '{{from}}'
  and pr.created_at < '{{to}}'
  and r.alias is not null
group by
  r.alias
union select 'gstat_r_prmerged,' || r.alias as repo,
  round(count(distinct pr.id) / {{n}}, 2) as metric
from
  gha_pull_requests pr,
  gha_repos r
where
  r.name = pr.dup_repo_name
  and r.id = pr.dup_repo_id
  and pr.merged_at is not null
  and pr.merged_at >= '{{from}}'
  and pr.merged_at < '{{to}}'
  and r.alias is not null
group by
  r.alias
union select 'gstat_r_prclosed,' || r.alias as repo,
  round(count(distinct pr.id) / {{n}}, 2) as metric
from
  gha_repos r,
  gha_pull_requests pr
where
  r.name = pr.dup_repo_name
  and r.id = pr.dup_repo_id
  and pr.merged_at is null
  and pr.closed_at >= '{{from}}'
  and pr.closed_at < '{{to}}'
  and r.alias is not null
group by
  r.alias
union select 'gstat_r_prcomments,' || i.alias as repo,
  round(count(distinct i.event_id) / {{n}}, 2) as metric
from
  gsa_ic_{{rnd}} i
where
  i.is_pull_request = false
  and i.actor_login in (select login from gsa_ok_logins_{{rnd}})
group by
  i.alias
union select 'gstat_r_prcommenters,' || i.alias as repo,
  count(distinct i.dup_actor_id) as metric
from
  gsa_ic_{{rnd}} i
where
  i.is_pull_request = false
  and i.actor_login in (select login from gsa_ok_logins_{{rnd}})
group by
  i.alias
union select 'gstat_r_icomments,' || i.alias as repo,
  round(count(distinct i.event_id) / {{n}}, 2) as metric
from
  gsa_ic_{{rnd}} i
where
  i.is_pull_request = true
  and i.actor_login in (select login from gsa_ok_logins_{{rnd}})
group by
  i.alias
union select 'gstat_r_icommenters,' || r.alias as repo,
  count(distinct i.dup_actor_id) as metric
from
  gha_issues i,
  gha_repos r
where
  i.dup_repo_id = r.id
  and i.dup_created_at >= '{{from}}'
  and i.dup_created_at < '{{to}}'
  and i.dup_type = 'IssueCommentEvent'
  and i.is_pull_request = true
  and (lower(i.dup_actor_login) {{exclude_bots}})
  and r.alias is not null
group by
  r.alias
union select 'gstat_r_reviewers,' || v.alias as repo,
  count(distinct v.actor) as metric
from
  gsa_rev_{{rnd}} v
where
  v.actor_login in (select login from gsa_ok_logins_{{rnd}})
group by
  v.alias
order by
  repo asc
;
