create temp table ph_base{{rnd}} as
  select repo_id,
    created_at,
    actor_id
  from
    gha_events
  where
    type in ('IssuesEvent', 'PullRequestEvent', 'PushEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 'PullRequestReviewEvent')
    and (lower(dup_actor_login) {{exclude_bots}})
  union select dup_repo_id as repo_id,
    dup_created_at as created_at,
    author_id as actor_id
  from
    gha_commits
  where
    dup_author_login is not null
    and (lower(dup_author_login) {{exclude_bots}})
  union select dup_repo_id as repo_id,
    dup_created_at as created_at,
    committer_id as actor_id
  from
    gha_commits
  where
    dup_committer_login is not null
    and (lower(dup_committer_login) {{exclude_bots}});
analyze ph_base{{rnd}};
create temp table ph_commits{{rnd}} as
  select dup_repo_id as repo_id,
    sha,
    dup_created_at as created_at,
    dup_actor_id as actor_id,
    author_id,
    committer_id,
    dup_author_login is not null as has_author,
    dup_committer_login is not null as has_committer,
    (lower(dup_actor_login) {{exclude_bots}}) as f_actor,
    (lower(dup_author_login) {{exclude_bots}}) as f_author,
    (lower(dup_committer_login) {{exclude_bots}}) as f_committer
  from
    gha_commits
  where
    dup_created_at >= now() - '1 year'::interval;
analyze ph_commits{{rnd}};
create temp table ph_aff_actors{{rnd}} as
  select c.repo_id,
    c.sha,
    c.created_at,
    a.company_name
  from
    ph_commits{{rnd}} c,
    gha_actors_affiliations a
  where
    c.f_actor
    and a.company_name != ''
    and c.actor_id = a.actor_id
    and a.dt_from <= c.created_at
    and a.dt_to > c.created_at;
analyze ph_aff_actors{{rnd}};
create temp table ph_aff_authors{{rnd}} as
  select c.repo_id,
    c.sha,
    c.created_at,
    a.company_name
  from
    ph_commits{{rnd}} c,
    gha_actors_affiliations a
  where
    c.has_author
    and c.f_author
    and a.company_name != ''
    and c.author_id = a.actor_id
    and a.dt_from <= c.created_at
    and a.dt_to > c.created_at;
analyze ph_aff_authors{{rnd}};
create temp table ph_aff_committers{{rnd}} as
  select c.repo_id,
    c.sha,
    c.created_at,
    a.company_name
  from
    ph_commits{{rnd}} c,
    gha_actors_affiliations a
  where
    c.has_committer
    and c.f_committer
    and a.company_name != ''
    and c.committer_id = a.actor_id
    and a.dt_from <= c.created_at
    and a.dt_to > c.created_at;
analyze ph_aff_committers{{rnd}};
create temp table ph_prs{{rnd}} as
  select id,
    dup_repo_id,
    created_at,
    closed_at,
    merged_at
  from
    gha_pull_requests
  where
    created_at >= now() - '1 year'::interval
    or (closed_at is not null and closed_at >= now() - '1 year'::interval)
    or (merged_at is not null and merged_at >= now() - '1 year'::interval);
analyze ph_prs{{rnd}};
create temp table ph_issues{{rnd}} as
  select id,
    dup_repo_id,
    created_at,
    closed_at,
    is_pull_request
  from
    gha_issues
  where
    is_pull_request = false
    and (created_at >= now() - '1 year'::interval or (closed_at is not null and closed_at >= now() - '1 year'::interval));
analyze ph_issues{{rnd}};
create temp table ph_push{{rnd}} as
  select r.repo_group,
    max(c.created_at) as maxd
  from
    gha_events c,
    gha_repos r
  where
    c.repo_id = r.id
    and r.repo_group is not null
    and c.type = 'PushEvent'
  group by
    r.repo_group;
analyze ph_push{{rnd}};

create temp table suffix_projects{{rnd}} as
  -- projects{{rnd}} for which we want to add a suffix
  select
    'none' as project,
    'cncf' as suffix;
analyze suffix_projects{{rnd}};
create temp table strip_projects{{rnd}} as
  -- projects{{rnd}} from which we want to remove a suffix
  select
    'shipwrightcncf' as project,
    'cncf' as strip;
analyze strip_projects{{rnd}};
create temp table skip_projects{{rnd}} as
  -- projects{{rnd}} which we want to skip with original mapping name
  select
    'shipwrightcncf' as project;
analyze skip_projects{{rnd}};
create temp table projects{{rnd}} as
  select distinct p.period as project,
    p.repo,
    last_value(p.time) over projects_by_time as last_release_date,
    last_value(p.title) over projects_by_time as last_release_tag,
    last_value(p.description) over projects_by_time as last_release_desc
  from
    sannotations_shared p
  left join
    skip_projects{{rnd}} sp
  on
    sp.project = p.period
  where
    sp.project is null
    and p.title != 'CNCF join date'
  window
    projects_by_time as (
      partition by p.period
      order by
        p.time asc
      range between current row
      and unbounded following
    )
  union select distinct p.period || sp.suffix as project,
    p.repo,
    last_value(p.time) over projects_by_time as last_release_date,
    last_value(p.title) over projects_by_time as last_release_tag,
    last_value(p.description) over projects_by_time as last_release_desc
  from
    suffix_projects{{rnd}} sp
  inner join
    sannotations_shared p
  on
    sp.project = p.period
  where
    p.title != 'CNCF join date'
  window
    projects_by_time as (
      partition by p.period
      order by
        p.time asc
      range between current row
      and unbounded following
    )
  union select distinct trim(trailing sp.strip from p.period) as project,
    p.repo,
    last_value(p.time) over projects_by_time as last_release_date,
    last_value(p.title) over projects_by_time as last_release_tag,
    last_value(p.description) over projects_by_time as last_release_desc
  from
    strip_projects{{rnd}} sp
  inner join
    sannotations_shared p
  on
    sp.project = p.period
  where
    p.title != 'CNCF join date'
  window
    projects_by_time as (
      partition by p.period
      order by
        p.time asc
      range between current row
      and unbounded following
    );
analyze projects{{rnd}};
create temp table contributors{{rnd}} as
  select r.repo_group,
    count(distinct e.actor_id) as contrib12,
    count(distinct e.actor_id) filter (where e.created_at >= now() - '6 months'::interval) as contrib6,
    count(distinct e.actor_id) filter (where e.created_at >= now() - '3 months'::interval) as contrib3,
    count(distinct e.actor_id) filter (where e.created_at >= now() - '6 months'::interval and e.created_at < now() - '3 months'::interval) as contribp3
  from (
      select repo_id,
        created_at,
        actor_id
      from
        ph_base{{rnd}}
      where
        created_at >= now() - '1 year'::interval
    ) e,
    gha_repos r
  where
    r.repo_group is not null
    and r.id = e.repo_id
  group by
    r.repo_group;
analyze contributors{{rnd}};
create temp table prev12_contributors{{rnd}} as
  select distinct r.repo_group,
    e.actor_id
  from (
      select repo_id,
        actor_id
      from
        ph_base{{rnd}}
      where
        created_at < now() - '1 year'::interval
    ) e,
    gha_repos r
  where
    r.repo_group is not null
    and r.id = e.repo_id
  group by
    r.repo_group,
    e.actor_id;
analyze prev12_contributors{{rnd}};
create temp table prev6_contributors{{rnd}} as
  select distinct r.repo_group,
    e.actor_id
  from (
      select repo_id,
        actor_id
      from
        ph_base{{rnd}}
      where
        created_at < now() - '6 months'::interval
    ) e,
    gha_repos r
  where
    r.repo_group is not null
    and r.id = e.repo_id
  group by
    r.repo_group,
    e.actor_id;
analyze prev6_contributors{{rnd}};
create temp table prev3_contributors{{rnd}} as
  select distinct r.repo_group,
    e.actor_id
  from (
      select repo_id,
        actor_id
      from
        ph_base{{rnd}}
      where
        created_at < now() - '3 months'::interval
    ) e,
    gha_repos r
  where
    r.repo_group is not null
    and r.id = e.repo_id
  group by
    r.repo_group,
    e.actor_id;
analyze prev3_contributors{{rnd}};
create temp table new12_contributors{{rnd}} as
  select r.repo_group,
    count(distinct e.actor_id) as ncontrib12
  from (
      select repo_id,
        actor_id
      from
        ph_base{{rnd}}
      where
        created_at >= now() - '1 year'::interval
    ) e
  join
    gha_repos r
  on
    r.id = e.repo_id
    and r.repo_group is not null
  left join
    prev12_contributors{{rnd}} pc
  on
    r.repo_group = pc.repo_group
    and e.actor_id = pc.actor_id
  where
    pc.actor_id is null
  group by
    r.repo_group;
analyze new12_contributors{{rnd}};
create temp table new6_contributors{{rnd}} as
  select r.repo_group,
    count(distinct e.actor_id) as ncontrib6,
    count(distinct e.actor_id) filter (where e.created_at < now() - '3 months'::interval) as ncontribp3
  from (
      select repo_id,
        created_at,
        actor_id
      from
        ph_base{{rnd}}
      where
        created_at >= now() - '6 months'::interval
    ) e
  join
    gha_repos r
  on
    r.id = e.repo_id
    and r.repo_group is not null
  left join
    prev6_contributors{{rnd}} pc
  on
    r.repo_group = pc.repo_group
    and e.actor_id = pc.actor_id
  where
    pc.actor_id is null
  group by
    r.repo_group;
analyze new6_contributors{{rnd}};
create temp table new3_contributors{{rnd}} as
  select r.repo_group,
    count(distinct e.actor_id) as ncontrib3
  from (
      select repo_id,
        actor_id
      from
        ph_base{{rnd}}
      where
        created_at >= now() - '3 months'::interval
    ) e
  join
    gha_repos r
  on
    r.id = e.repo_id
    and r.repo_group is not null
  left join
    prev3_contributors{{rnd}} pc
  on
    r.repo_group = pc.repo_group
    and e.actor_id = pc.actor_id
  where
    pc.actor_id is null
  group by
    r.repo_group;
analyze new3_contributors{{rnd}};
create temp table commits{{rnd}} as
  select r.repo_group,
    count(distinct e.sha) as comm12,
    count(distinct e.sha) filter (where e.created_at >= now() - '6 months'::interval) as comm6,
    count(distinct e.sha) filter (where e.created_at >= now() - '3 months'::interval) as comm3,
    count(distinct e.sha) filter (where e.created_at >= now() - '6 months'::interval and e.created_at < now() - '3 months'::interval) as commp3,
    count(distinct e.actor_id) as acomm12,
    count(distinct e.actor_id) filter (where e.created_at >= now() - '6 months'::interval) as acomm6,
    count(distinct e.actor_id) filter (where e.created_at >= now() - '3 months'::interval) as acomm3,
    count(distinct e.actor_id) filter (where e.created_at >= now() - '6 months'::interval and e.created_at < now() - '3 months'::interval) as acommp3
  from (
      select repo_id,
        sha,
        created_at,
        actor_id
      from
        ph_commits{{rnd}}
      where
        f_actor
      union select repo_id,
        sha,
        created_at,
        author_id as actor_id
      from
        ph_commits{{rnd}}
      where
        has_author
        and f_author
      union select repo_id,
        sha,
        created_at,
        committer_id as actor_id
      from
        ph_commits{{rnd}}
      where
        has_committer
        and f_committer
    ) e,
    gha_repos r
  where
    r.repo_group is not null
    and r.id = e.repo_id
  group by
    r.repo_group;
analyze commits{{rnd}};
create temp table prs_opened{{rnd}} as
  select r.repo_group,
    count(distinct pr.id) as pr12,
    count(distinct pr.id) filter (where pr.created_at >= now() - '6 months'::interval) as pr6,
    count(distinct pr.id) filter (where pr.created_at >= now() - '3 months'::interval) as pr3,
    count(distinct pr.id) filter (where pr.created_at >= now() - '6 months'::interval and pr.created_at < now() - '3 months'::interval) as prp3
  from
    ph_prs{{rnd}} pr,
    gha_repos r
  where
    r.repo_group is not null
    and r.id = pr.dup_repo_id
    and pr.created_at >= now() - '1 year'::interval
  group by
    r.repo_group;
analyze prs_opened{{rnd}};
create temp table prs_closed{{rnd}} as
  select r.repo_group,
    count(distinct pr.id) as pr12,
    count(distinct pr.id) filter (where pr.closed_at >= now() - '6 months'::interval) as pr6,
    count(distinct pr.id) filter (where pr.closed_at >= now() - '3 months'::interval) as pr3,
    count(distinct pr.id) filter (where pr.closed_at >= now() - '6 months'::interval and pr.closed_at < now() - '3 months'::interval) as prp3
  from
    ph_prs{{rnd}} pr,
    gha_repos r
  where
    r.repo_group is not null
    and pr.closed_at is not null
    and r.id = pr.dup_repo_id
    and pr.closed_at >= now() - '1 year'::interval
  group by
    r.repo_group;
analyze prs_closed{{rnd}};
create temp table prs_merged{{rnd}} as
  select r.repo_group,
    count(distinct pr.id) as pr12,
    count(distinct pr.id) filter (where pr.merged_at >= now() - '6 months'::interval) as pr6,
    count(distinct pr.id) filter (where pr.merged_at >= now() - '3 months'::interval) as pr3,
    count(distinct pr.id) filter (where pr.merged_at >= now() - '6 months'::interval and pr.merged_at < now() - '3 months'::interval) as prp3
  from
    ph_prs{{rnd}} pr,
    gha_repos r
  where
    r.repo_group is not null
    and pr.merged_at is not null
    and r.id = pr.dup_repo_id
    and pr.merged_at >= now() - '1 year'::interval
  group by
    r.repo_group;
analyze prs_merged{{rnd}};
create temp table issues_opened{{rnd}} as
  select r.repo_group,
    count(distinct i.id) as i12,
    count(distinct i.id) filter (where i.created_at >= now() - '6 months'::interval) as i6,
    count(distinct i.id) filter (where i.created_at >= now() - '3 months'::interval) as i3,
    count(distinct i.id) filter (where i.created_at >= now() - '6 months'::interval and i.created_at < now() - '3 months'::interval) as ip3
  from
    ph_issues{{rnd}} i,
    gha_repos r
  where
    r.repo_group is not null
    and i.is_pull_request = false
    and r.id = i.dup_repo_id
    and i.created_at >= now() - '1 year'::interval
  group by
    r.repo_group;
analyze issues_opened{{rnd}};
create temp table issues_closed{{rnd}} as
  select r.repo_group,
    count(distinct i.id) as i12,
    count(distinct i.id) filter (where i.closed_at >= now() - '6 months'::interval) as i6,
    count(distinct i.id) filter (where i.closed_at >= now() - '3 months'::interval) as i3,
    count(distinct i.id) filter (where i.closed_at >= now() - '6 months'::interval and i.closed_at < now() - '3 months'::interval) as ip3
  from
    ph_issues{{rnd}} i,
    gha_repos r
  where
    r.repo_group is not null
    and i.is_pull_request = false
    and i.closed_at is not null
    and r.id = i.dup_repo_id
    and i.closed_at >= now() - '1 year'::interval
  group by
    r.repo_group;
analyze issues_closed{{rnd}};
create temp table issue_ratio{{rnd}} as
  select io.repo_group,
    case ic.i3 when 0 then -1.0 else io.i3::float / ic.i3::float end as r3,
    case ic.ip3 when 0 then -1.0 else io.ip3::float / ic.ip3::float end as rp3
  from
    issues_opened{{rnd}} io,
    issues_closed{{rnd}} ic
  where
    io.repo_group = ic.repo_group;
analyze issue_ratio{{rnd}};
create temp table recent_issues{{rnd}} as
  select distinct id,
    user_id,
    created_at
  from
    gha_issues
  where
    created_at >= now() - '6 months'::interval;
analyze recent_issues{{rnd}};
create temp table tdiffs{{rnd}} as
  select i2.updated_at - i.created_at as diff,
    r.repo_group
  from
    recent_issues{{rnd}} i,
    gha_repos r,
    gha_issues i2
  where
    i.id = i2.id
    and r.name = i2.dup_repo_name
    and (lower(i2.dup_actor_login) {{exclude_bots}})
    and i2.event_id in (
      select event_id
      from
        gha_issues sub
      where
        sub.dup_actor_id != i.user_id
        and sub.id = i.id
        and sub.updated_at > i.created_at + '30 seconds'::interval
        and sub.dup_type like '%Event'
      order by
        sub.updated_at asc
      limit 1
    );
analyze tdiffs{{rnd}};
create temp table react_time{{rnd}} as
  select repo_group,
    percentile_disc(0.15) within group (order by diff asc) as p15,
    percentile_disc(0.5) within group (order by diff asc) as med,
    percentile_disc(0.85) within group (order by diff asc) as p85
  from
    tdiffs{{rnd}}
  where
    repo_group is not null
  group by
    repo_group;
analyze react_time{{rnd}};
create temp table pr_ratio{{rnd}} as
  select po.repo_group,
    case pc.pr3 when 0 then -1.0 else po.pr3::float / pc.pr3::float end as r3,
    case pc.prp3 when 0 then -1.0 else po.prp3::float / pc.prp3::float end as rp3
  from
    prs_opened{{rnd}} po,
    prs_closed{{rnd}} pc
  where
    po.repo_group = pc.repo_group;
analyze pr_ratio{{rnd}};
create temp table commits_counts{{rnd}} as
  select r.repo_group,
    count(distinct e.sha) as n12,
    count(distinct e.sha) filter (where e.created_at >= now() - '3 months'::interval) as n3
  from
    ph_commits{{rnd}} e,
    gha_repos r
  where
    r.repo_group is not null
    and r.id = e.repo_id
    and (e.f_actor or e.f_author or e.f_committer)
  group by
    r.repo_group;
analyze commits_counts{{rnd}};
create temp table known_commits_actors_counts{{rnd}} as
  select r.repo_group,
    count(distinct e.sha) as n12,
    count(distinct e.sha) filter (where e.created_at >= now() - '3 months'::interval) as n3
  from
    ph_aff_actors{{rnd}} e,
    gha_repos r
  where
    r.repo_group is not null
    and e.company_name != 'NotFound'
    and e.company_name != '(Unknown)'
    and r.id = e.repo_id
  group by
    r.repo_group;
analyze known_commits_actors_counts{{rnd}};
create temp table known_commits_authors_counts{{rnd}} as
  select r.repo_group,
    count(distinct e.sha) as n12,
    count(distinct e.sha) filter (where e.created_at >= now() - '3 months'::interval) as n3
  from
    ph_aff_authors{{rnd}} e,
    gha_repos r
  where
    r.repo_group is not null
    and e.company_name != 'NotFound'
    and e.company_name != '(Unknown)'
    and r.id = e.repo_id
  group by
    r.repo_group;
analyze known_commits_authors_counts{{rnd}};
create temp table known_commits_committers_counts{{rnd}} as
  select r.repo_group,
    count(distinct e.sha) as n12,
    count(distinct e.sha) filter (where e.created_at >= now() - '3 months'::interval) as n3
  from
    ph_aff_committers{{rnd}} e,
    gha_repos r
  where
    r.repo_group is not null
    and e.company_name != 'NotFound'
    and e.company_name != '(Unknown)'
    and r.id = e.repo_id
  group by
    r.repo_group;
analyze known_commits_committers_counts{{rnd}};
create temp table company_commits_actors_counts{{rnd}} as
  select r.repo_group,
    e.company_name,
    count(distinct e.sha) as n12,
    count(distinct e.sha) filter (where e.created_at >= now() - '3 months'::interval) as n3
  from
    ph_aff_actors{{rnd}} e,
    gha_repos r
  where
    r.repo_group is not null
    and r.id = e.repo_id
  group by
    r.repo_group,
    e.company_name;
analyze company_commits_actors_counts{{rnd}};
create temp table company_commits_authors_counts{{rnd}} as
  select r.repo_group,
    e.company_name,
    count(distinct e.sha) as n12,
    count(distinct e.sha) filter (where e.created_at >= now() - '3 months'::interval) as n3
  from
    ph_aff_authors{{rnd}} e,
    gha_repos r
  where
    r.repo_group is not null
    and r.id = e.repo_id
  group by
    r.repo_group,
    e.company_name;
analyze company_commits_authors_counts{{rnd}};
create temp table company_commits_committers_counts{{rnd}} as
  select r.repo_group,
    e.company_name,
    count(distinct e.sha) as n12,
    count(distinct e.sha) filter (where e.created_at >= now() - '3 months'::interval) as n3
  from
    ph_aff_committers{{rnd}} e,
    gha_repos r
  where
    r.repo_group is not null
    and r.id = e.repo_id
  group by
    r.repo_group,
    e.company_name;
analyze company_commits_committers_counts{{rnd}};
create temp table top_all_actors_3{{rnd}} as
  select i.repo_group,
    case i.a > 0 when true then round((i.c::numeric / i.a::numeric) * 100.0, 2)::text || '% ' || i.cname else '-' end as top
  from (
    select distinct c.repo_group,
      first_value(c.n3) over companies_by_commits as c,
      first_value(a.n3) over companies_by_commits as a,
      first_value(c.company_name) over companies_by_commits as cname
    from
      commits_counts{{rnd}} a,
      company_commits_actors_counts{{rnd}} c
    where
      a.repo_group = c.repo_group
    window
      companies_by_commits as (
        partition by c.repo_group
        order by
          c.n3 desc,
          c.company_name asc
        range between unbounded preceding
        and current row
      )
  ) i;
analyze top_all_actors_3{{rnd}};
create temp table top_known_actors_3{{rnd}} as
  select i.repo_group,
    case i.k > 0 when true then round((i.c::numeric / i.k::numeric) * 100.0, 2)::text || '% ' || i.cname else '-' end as top
  from (
    select distinct c.repo_group,
      first_value(c.n3) over companies_by_commits as c,
      first_value(k.n3) over companies_by_commits as k,
      first_value(c.company_name) over companies_by_commits as cname
    from
      known_commits_actors_counts{{rnd}} k,
      company_commits_actors_counts{{rnd}} c
    where
      k.repo_group = c.repo_group
    window
      companies_by_commits as (
        partition by c.repo_group
        order by
          c.n3 desc,
          c.company_name asc
        range between unbounded preceding
        and current row
      )
  ) i;
analyze top_known_actors_3{{rnd}};
create temp table top_all_authors_3{{rnd}} as
  select i.repo_group,
    case i.a > 0 when true then round((i.c::numeric / i.a::numeric) * 100.0, 2)::text || '% ' || i.cname else '-' end as top
  from (
    select distinct c.repo_group,
      first_value(c.n3) over companies_by_commits as c,
      first_value(a.n3) over companies_by_commits as a,
      first_value(c.company_name) over companies_by_commits as cname
    from
      commits_counts{{rnd}} a,
      company_commits_authors_counts{{rnd}} c
    where
      a.repo_group = c.repo_group
    window
      companies_by_commits as (
        partition by c.repo_group
        order by
          c.n3 desc,
          c.company_name asc
        range between unbounded preceding
        and current row
      )
  ) i;
analyze top_all_authors_3{{rnd}};
create temp table top_known_authors_3{{rnd}} as
  select i.repo_group,
    case i.k > 0 when true then round((i.c::numeric / i.k::numeric) * 100.0, 2)::text || '% ' || i.cname else '-' end as top
  from (
    select distinct c.repo_group,
      first_value(c.n3) over companies_by_commits as c,
      first_value(k.n3) over companies_by_commits as k,
      first_value(c.company_name) over companies_by_commits as cname
    from
      known_commits_authors_counts{{rnd}} k,
      company_commits_authors_counts{{rnd}} c
    where
      k.repo_group = c.repo_group
    window
      companies_by_commits as (
        partition by c.repo_group
        order by
          c.n3 desc,
          c.company_name asc
        range between unbounded preceding
        and current row
      )
  ) i;
analyze top_known_authors_3{{rnd}};
create temp table top_all_committers_3{{rnd}} as
  select i.repo_group,
    case i.a > 0 when true then round((i.c::numeric / i.a::numeric) * 100.0, 2)::text || '% ' || i.cname else '-' end as top
  from (
    select distinct c.repo_group,
      first_value(c.n3) over companies_by_commits as c,
      first_value(a.n3) over companies_by_commits as a,
      first_value(c.company_name) over companies_by_commits as cname
    from
      commits_counts{{rnd}} a,
      company_commits_committers_counts{{rnd}} c
    where
      a.repo_group = c.repo_group
    window
      companies_by_commits as (
        partition by c.repo_group
        order by
          c.n3 desc,
          c.company_name asc
        range between unbounded preceding
        and current row
      )
  ) i;
analyze top_all_committers_3{{rnd}};
create temp table top_known_committers_3{{rnd}} as
  select i.repo_group,
    case i.k > 0 when true then round((i.c::numeric / i.k::numeric) * 100.0, 2)::text || '% ' || i.cname else '-' end as top
  from (
    select distinct c.repo_group,
      first_value(c.n3) over companies_by_commits as c,
      first_value(k.n3) over companies_by_commits as k,
      first_value(c.company_name) over companies_by_commits as cname
    from
      known_commits_committers_counts{{rnd}} k,
      company_commits_committers_counts{{rnd}} c
    where
      k.repo_group = c.repo_group
    window
      companies_by_commits as (
        partition by c.repo_group
        order by
          c.n3 desc,
          c.company_name asc
        range between unbounded preceding
        and current row
      )
  ) i;
analyze top_known_committers_3{{rnd}};
create temp table top_all_actors_12{{rnd}} as
  select i.repo_group,
    case i.a > 0 when true then round((i.c::numeric / i.a::numeric) * 100.0, 2)::text || '% ' || i.cname else '-' end as top
  from (
    select distinct c.repo_group,
      first_value(c.n12) over companies_by_commits as c,
      first_value(a.n12) over companies_by_commits as a,
      first_value(c.company_name) over companies_by_commits as cname
    from
      commits_counts{{rnd}} a,
      company_commits_actors_counts{{rnd}} c
    where
      a.repo_group = c.repo_group
    window
      companies_by_commits as (
        partition by c.repo_group
        order by
          c.n12 desc,
          c.company_name asc
        range between unbounded preceding
        and current row
      )
  ) i;
analyze top_all_actors_12{{rnd}};
create temp table top_known_actors_12{{rnd}} as
  select i.repo_group,
    case i.k > 0 when true then round((i.c::numeric / i.k::numeric) * 100.0, 2)::text || '% ' || i.cname else '-' end as top
  from (
    select distinct c.repo_group,
      first_value(c.n12) over companies_by_commits as c,
      first_value(k.n12) over companies_by_commits as k,
      first_value(c.company_name) over companies_by_commits as cname
    from
      known_commits_actors_counts{{rnd}} k,
      company_commits_actors_counts{{rnd}} c
    where
      k.repo_group = c.repo_group
    window
      companies_by_commits as (
        partition by c.repo_group
        order by
          c.n12 desc,
          c.company_name asc
        range between unbounded preceding
        and current row
      )
  ) i;
analyze top_known_actors_12{{rnd}};
create temp table top_all_authors_12{{rnd}} as
  select i.repo_group,
    case i.a > 0 when true then round((i.c::numeric / i.a::numeric) * 100.0, 2)::text || '% ' || i.cname else '-' end as top
  from (
    select distinct c.repo_group,
      first_value(c.n12) over companies_by_commits as c,
      first_value(a.n12) over companies_by_commits as a,
      first_value(c.company_name) over companies_by_commits as cname
    from
      commits_counts{{rnd}} a,
      company_commits_authors_counts{{rnd}} c
    where
      a.repo_group = c.repo_group
    window
      companies_by_commits as (
        partition by c.repo_group
        order by
          c.n12 desc,
          c.company_name asc
        range between unbounded preceding
        and current row
      )
  ) i;
analyze top_all_authors_12{{rnd}};
create temp table top_known_authors_12{{rnd}} as
  select i.repo_group,
    case i.k > 0 when true then round((i.c::numeric / i.k::numeric) * 100.0, 2)::text || '% ' || i.cname else '-' end as top
  from (
    select distinct c.repo_group,
      first_value(c.n12) over companies_by_commits as c,
      first_value(k.n12) over companies_by_commits as k,
      first_value(c.company_name) over companies_by_commits as cname
    from
      known_commits_authors_counts{{rnd}} k,
      company_commits_authors_counts{{rnd}} c
    where
      k.repo_group = c.repo_group
    window
      companies_by_commits as (
        partition by c.repo_group
        order by
          c.n12 desc,
          c.company_name asc
        range between unbounded preceding
        and current row
      )
  ) i;
analyze top_known_authors_12{{rnd}};
create temp table top_all_committers_12{{rnd}} as
  select i.repo_group,
    case i.a > 0 when true then round((i.c::numeric / i.a::numeric) * 100.0, 2)::text || '% ' || i.cname else '-' end as top
  from (
    select distinct c.repo_group,
      first_value(c.n12) over companies_by_commits as c,
      first_value(a.n12) over companies_by_commits as a,
      first_value(c.company_name) over companies_by_commits as cname
    from
      commits_counts{{rnd}} a,
      company_commits_committers_counts{{rnd}} c
    where
      a.repo_group = c.repo_group
    window
      companies_by_commits as (
        partition by c.repo_group
        order by
          c.n12 desc,
          c.company_name asc
        range between unbounded preceding
        and current row
      )
  ) i;
analyze top_all_committers_12{{rnd}};
create temp table top_known_committers_12{{rnd}} as
  select i.repo_group,
    case i.k > 0 when true then round((i.c::numeric / i.k::numeric) * 100.0, 2)::text || '% ' || i.cname else '-' end as top
  from (
    select distinct c.repo_group,
      first_value(c.n12) over companies_by_commits as c,
      first_value(k.n12) over companies_by_commits as k,
      first_value(c.company_name) over companies_by_commits as cname
    from
      known_commits_committers_counts{{rnd}} k,
      company_commits_committers_counts{{rnd}} c
    where
      k.repo_group = c.repo_group
    window
      companies_by_commits as (
        partition by c.repo_group
        order by
          c.n12 desc,
          c.company_name asc
        range between unbounded preceding
        and current row
      )
  ) i;
analyze top_known_committers_12{{rnd}};
create temp table repo_groups{{rnd}} as
  select distinct repo_group
  from
    gha_repos
  where
    repo_group is not null;
analyze repo_groups{{rnd}};

select
  'phealth,' || project || ',ltag' as name,
  'Releases: Last release',
  last_release_date,
  0.0,
  last_release_tag
from
  projects{{rnd}}
union select
  'phealth,' || project || ',ldate' as name,
  'Releases: Last release date',
  last_release_date,
  0.0,
  to_char(last_release_date, 'MM/DD/YYYY')
from
  projects{{rnd}}
union select
  'phealth,' || project || ',ldesc' as name,
  'Releases: Last release description',
  last_release_date,
  0.0,
  last_release_desc
from
  projects{{rnd}}
union select 'phealth,' || p.repo_group || ',lcomm' as name,
  'Commits: Last commit date',
  p.maxd,
  0.0,
  to_char(p.maxd, 'MM/DD/YYYY HH12:MI:SS pm')
from
  ph_push{{rnd}} p
union select 'phealth,' || rg.repo_group || ',lcomm' as name,
  'Commits: Last commit date',
  '1980-01-01 00:00:00',
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  not exists (select 1 from ph_push{{rnd}} p where p.repo_group = rg.repo_group)
union select 'phealth,' || p.repo_group || ',active' as name,
  'Activity status',
  p.maxd,
  0.0,
  CASE WHEN DATE_PART('day', now() - p.maxd) > 90 THEN 'Inactive' ELSE 'Active' END
from
  ph_push{{rnd}} p
union select 'phealth,' || rg.repo_group || ',active' as name,
  'Activity status',
  '1980-01-01 00:00:00',
  0.0,
  'Unknown'
from
  repo_groups{{rnd}} rg
where
  not exists (select 1 from ph_push{{rnd}} p where p.repo_group = rg.repo_group)
union select 'phealth,' || p.repo_group || ',lcommd' as name,
  'Commits: Days since last commit',
  p.maxd,
  0.0,
  DATE_PART('day', now() - p.maxd)::text || ' days'
from
  ph_push{{rnd}} p
union select 'phealth,' || rg.repo_group || ',lcommd' as name,
  'Commits: Days since last commit',
  '1980-01-01 00:00:00',
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  not exists (select 1 from ph_push{{rnd}} p where p.repo_group = rg.repo_group)
union select 'phealth,' || repo_group || ',acomm3' as name,
  'Committers: Number of committers in the last 3 months',
  now(),
  0.0,
  acomm3::text
from
  commits{{rnd}}
union select 'phealth,' || rg.repo_group || ',acomm3' as name,
  'Committers: Number of committers in the last 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from commits{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',acomm6' as name,
  'Committers: Number of committers in the last 6 months',
  now(),
  0.0,
  acomm6::text
from
  commits{{rnd}}
union select 'phealth,' || rg.repo_group || ',acomm6' as name,
  'Committers: Number of committers in the last 6 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from commits{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',acomm12' as name,
  'Committers: Number of committers in the last 12 months',
  now(),
  0.0,
  acomm12::text
from
  commits{{rnd}}
union select 'phealth,' || rg.repo_group || ',acomm12' as name,
  'Committers: Number of committers in the last 12 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from commits{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',acommp3' as name,
  'Committers: Number of committers in the last 3 months (previous 3 months)',
  now(),
  0.0,
  acommp3::text
from
  commits{{rnd}}
union select 'phealth,' || rg.repo_group || ',acommp3' as name,
  'Committers: Number of committers in the last 3 months (previous 3 months)',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from commits{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',acomm' as name,
  'Committers: Number of committers in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  case acomm3 > acommp3 when true then 'Up' else case acomm3 < acommp3 when true then 'Down' else 'Flat' end end
from
  commits{{rnd}}
union select 'phealth,' || rg.repo_group || ',acomm' as name,
  'Committers: Number of committers in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from commits{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',comm3' as name,
  'Commits: Number of commits in the last 3 months',
  now(),
  0.0,
  comm3::text
from
  commits{{rnd}}
union select 'phealth,' || rg.repo_group || ',comm3' as name,
  'Commits: Number of commits in the last 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from commits{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',comm6' as name,
  'Commits: Number of commits in the last 6 months',
  now(),
  0.0,
  comm6::text
from
  commits{{rnd}}
union select 'phealth,' || rg.repo_group || ',comm6' as name,
  'Commits: Number of commits in the last 6 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from commits{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',comm12' as name,
  'Commits: Number of commits in the last 12 months',
  now(),
  0.0,
  comm12::text
from
  commits{{rnd}}
union select 'phealth,' || rg.repo_group || ',comm12' as name,
  'Commits: Number of commits in the last 12 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from commits{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',commp3' as name,
  'Commits: Number of commits in the last 3 months (previous 3 months)',
  now(),
  0.0,
  commp3::text
from
  commits{{rnd}}
union select 'phealth,' || rg.repo_group || ',commp3' as name,
  'Commits: Number of commits in the last 3 months (previous 3 months)',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from commits{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',comm' as name,
  'Commits: Number of commits in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  case comm3 > commp3 when true then 'Up' else case comm3 < commp3 when true then 'Down' else 'Flat' end end
from
  commits{{rnd}}
union select 'phealth,' || rg.repo_group || ',comm' as name,
  'Commits: Number of commits in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from commits{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',contr3' as name,
  'Contributors: Number of contributors in the last 3 months',
  now(),
  0.0,
  contrib3::text
from
  contributors{{rnd}}
union select 'phealth,' || rg.repo_group || ',contr3' as name,
  'Contributors: Number of contributors in the last 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from contributors{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',contr6' as name,
  'Contributors: Number of contributors in the last 6 months',
  now(),
  0.0,
  contrib6::text
from
  contributors{{rnd}}
union select 'phealth,' || rg.repo_group || ',contr6' as name,
  'Contributors: Number of contributors in the last 6 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from contributors{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',contr12' as name,
  'Contributors: Number of contributors in the last 12 months',
  now(),
  0.0,
  contrib12::text
from
  contributors{{rnd}}
union select 'phealth,' || rg.repo_group || ',contr12' as name,
  'Contributors: Number of contributors in the last 12 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from contributors{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',contrp3' as name,
  'Contributors: Number of contributors in the last 3 months (previous 3 months)',
  now(),
  0.0,
  contribp3::text
from
  contributors{{rnd}}
union select 'phealth,' || rg.repo_group || ',contrp3' as name,
  'Contributors: Number of contributors in the last 3 months (previous 3 months)',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from contributors{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',contr' as name,
  'Contributors: Number of contributors in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  case contrib3 > contribp3 when true then 'Up' else case contrib3 < contribp3 when true then 'Down' else 'Flat' end end
from
  contributors{{rnd}}
union select 'phealth,' || rg.repo_group || ',contr' as name,
  'Contributors: Number of contributors in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from contributors{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',opr3' as name,
  'PRs: Number of PRs opened in the last 3 months',
  now(),
  0.0,
  pr3::text
from
  prs_opened{{rnd}}
union select 'phealth,' || rg.repo_group || ',opr3' as name,
  'PRs: Number of PRs opened in the last 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_opened{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',opr6' as name,
  'PRs: Number of PRs opened in the last 6 months',
  now(),
  0.0,
  pr6::text
from
  prs_opened{{rnd}}
union select 'phealth,' || rg.repo_group || ',opr6' as name,
  'PRs: Number of PRs opened in the last 6 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_opened{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',opr12' as name,
  'PRs: Number of PRs opened in the last 12 months',
  now(),
  0.0,
  pr12::text
from
  prs_opened{{rnd}}
union select 'phealth,' || rg.repo_group || ',opr12' as name,
  'PRs: Number of PRs opened in the last 12 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_opened{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',oprp3' as name,
  'PRs: Number of PRs opened in the last 3 months (previous 3 months)',
  now(),
  0.0,
  prp3::text
from
  prs_opened{{rnd}}
union select 'phealth,' || rg.repo_group || ',oprp3' as name,
  'PRs: Number of PRs opened in the last 3 months (previous 3 months)',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_opened{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',opr' as name,
  'PRs: Number of PRs opened in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  case pr3 > prp3 when true then 'Up' else case pr3 < prp3 when true then 'Down' else 'Flat' end end
from
  prs_opened{{rnd}}
union select 'phealth,' || rg.repo_group || ',opr' as name,
  'PRs: Number of PRs opened in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_opened{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',cpr3' as name,
  'PRs: Number of PRs closed in the last 3 months',
  now(),
  0.0,
  pr3::text
from
  prs_closed{{rnd}}
union select 'phealth,' || rg.repo_group || ',cpr3' as name,
  'PRs: Number of PRs closed in the last 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_closed{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',cpr6' as name,
  'PRs: Number of PRs closed in the last 6 months',
  now(),
  0.0,
  pr6::text
from
  prs_closed{{rnd}}
union select 'phealth,' || rg.repo_group || ',cpr6' as name,
  'PRs: Number of PRs closed in the last 6 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_closed{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',cpr12' as name,
  'PRs: Number of PRs closed in the last 12 months',
  now(),
  0.0,
  pr12::text
from
  prs_closed{{rnd}}
union select 'phealth,' || rg.repo_group || ',cpr12' as name,
  'PRs: Number of PRs closed in the last 12 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_closed{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',cprp3' as name,
  'PRs: Number of PRs closed in the last 3 months (previous 3 months)',
  now(),
  0.0,
  prp3::text
from
  prs_closed{{rnd}}
union select 'phealth,' || rg.repo_group || ',cprp3' as name,
  'PRs: Number of PRs closed in the last 3 months (previous 3 months)',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_closed{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',cpr' as name,
  'PRs: Number of PRs closed in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  case pr3 > prp3 when true then 'Up' else case pr3 < prp3 when true then 'Down' else 'Flat' end end
from
  prs_closed{{rnd}}
union select 'phealth,' || rg.repo_group || ',cpr' as name,
  'PRs: Number of PRs closed in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_closed{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',mpr3' as name,
  'PRs: Number of PRs merged in the last 3 months',
  now(),
  0.0,
  pr3::text
from
  prs_merged{{rnd}}
union select 'phealth,' || rg.repo_group || ',mpr3' as name,
  'PRs: Number of PRs merged in the last 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_merged{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',mpr6' as name,
  'PRs: Number of PRs merged in the last 6 months',
  now(),
  0.0,
  pr6::text
from
  prs_merged{{rnd}}
union select 'phealth,' || rg.repo_group || ',mpr6' as name,
  'PRs: Number of PRs merged in the last 6 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_merged{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',mpr12' as name,
  'PRs: Number of PRs merged in the last 12 months',
  now(),
  0.0,
  pr12::text
from
  prs_merged{{rnd}}
union select 'phealth,' || rg.repo_group || ',mpr12' as name,
  'PRs: Number of PRs merged in the last 12 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_merged{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',mprp3' as name,
  'PRs: Number of PRs merged in the last 3 months (previous 3 months)',
  now(),
  0.0,
  prp3::text
from
  prs_merged{{rnd}}
union select 'phealth,' || rg.repo_group || ',mprp3' as name,
  'PRs: Number of PRs merged in the last 3 months (previous 3 months)',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_merged{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',mpr' as name,
  'PRs: Number of PRs merged in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  case pr3 > prp3 when true then 'Up' else case pr3 < prp3 when true then 'Down' else 'Flat' end end
from
  prs_merged{{rnd}}
union select 'phealth,' || rg.repo_group || ',mpr' as name,
  'PRs: Number of PRs merged in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_merged{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',ip15' as name,
  'Issues: 15th percentile of time to respond to issues',
  now(),
  0.0,
  p15::text
from
  react_time{{rnd}}
union select 'phealth,' || rg.repo_group || ',ip15' as name,
  'Issues: 15th percentile of time to respond to issues',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from react_time{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',imed' as name,
  'Issues: Median time to respond to issues',
  now(),
  0.0,
  med::text
from
  react_time{{rnd}}
union select 'phealth,' || rg.repo_group || ',imed' as name,
  'Issues: Median time to respond to issues',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from react_time{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',ip85' as name,
  'Issues: 85th percentile of time to respond to issues',
  now(),
  0.0,
  p85::text
from
  react_time{{rnd}}
union select 'phealth,' || rg.repo_group || ',ip85' as name,
  'Issues: 85th percentile of time to respond to issues',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from react_time{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',pro2c' as name,
  'PRs: Opened to closed rate in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  case r3 < 0 or rp3 < 0 when true then '-' else case r3 > rp3 when true then 'Up' else case r3 < rp3 when true then 'Down' else 'Flat' end end end
from
  pr_ratio{{rnd}}
union select 'phealth,' || rg.repo_group || ',pro2c' as name,
  'PRs: Opened to closed rate in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from pr_ratio{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || po.repo_group || ',pro2c3' as name,
  'PRs: Opened to closed rate in the last 3 months',
  now(),
  0.0,
  case pc.pr3 when 0 then '-' else round(po.pr3::numeric / pc.pr3::numeric, 2)::text end
from
  prs_opened{{rnd}} po,
  prs_closed{{rnd}} pc
where
  po.repo_group = pc.repo_group
union select 'phealth,' || rg.repo_group || ',pro2c3' as name,
  'PRs: Opened to closed rate in the last 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_opened{{rnd}} po, prs_closed{{rnd}} pc where po.repo_group = pc.repo_group and pc.repo_group = rg.repo_group) = 0
union select 'phealth,' || po.repo_group || ',pro2cp3' as name,
  'PRs: Opened to closed rate in the last 3 months (previous 3 months)',
  now(),
  0.0,
  case pc.prp3 when 0 then '-' else round(po.prp3::numeric / pc.prp3::numeric, 2)::text end
from
  prs_opened{{rnd}} po,
  prs_closed{{rnd}} pc
where
  po.repo_group = pc.repo_group
union select 'phealth,' || rg.repo_group || ',pro2cp3' as name,
  'PRs: Opened to closed rate in the last 3 months (previous 3 months)',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_opened{{rnd}} po, prs_closed{{rnd}} pc where po.repo_group = pc.repo_group and pc.repo_group = rg.repo_group) = 0
union select 'phealth,' || po.repo_group || ',pro2c6' as name,
  'PRs: Opened to closed rate in the last 6 months',
  now(),
  0.0,
  case pc.pr6 when 0 then '-' else round(po.pr6::numeric / pc.pr6::numeric, 2)::text end
from
  prs_opened{{rnd}} po,
  prs_closed{{rnd}} pc
where
  po.repo_group = pc.repo_group
union select 'phealth,' || rg.repo_group || ',pro2c6' as name,
  'PRs: Opened to closed rate in the last 6 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_opened{{rnd}} po, prs_closed{{rnd}} pc where po.repo_group = pc.repo_group and pc.repo_group = rg.repo_group) = 0
union select 'phealth,' || po.repo_group || ',pro2c12' as name,
  'PRs: Opened to closed rate in the last 12 months',
  now(),
  0.0,
  case pc.pr12 when 0 then '-' else round(po.pr12::numeric / pc.pr12::numeric, 2)::text end
from
  prs_opened{{rnd}} po,
  prs_closed{{rnd}} pc
where
  po.repo_group = pc.repo_group
union select 'phealth,' || rg.repo_group || ',pro2c12' as name,
  'PRs: Opened to closed rate in the last 12 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from prs_opened{{rnd}} po, prs_closed{{rnd}} pc where po.repo_group = pc.repo_group and pc.repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',oi3' as name,
  'Issues: Number of issues opened in the last 3 months',
  now(),
  0.0,
  i3::text
from
  issues_opened{{rnd}}
union select 'phealth,' || rg.repo_group || ',oi3' as name,
  'Issues: Number of issues opened in the last 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from issues_opened{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',oi6' as name,
  'Issues: Number of issues opened in the last 6 months',
  now(),
  0.0,
  i6::text
from
  issues_opened{{rnd}}
union select 'phealth,' || rg.repo_group || ',oi6' as name,
  'Issues: Number of issues opened in the last 6 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from issues_opened{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',oi12' as name,
  'Issues: Number of issues opened in the last 12 months',
  now(),
  0.0,
  i12::text
from
  issues_opened{{rnd}}
union select 'phealth,' || rg.repo_group || ',oi12' as name,
  'Issues: Number of issues opened in the last 12 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from issues_opened{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',oip3' as name,
  'Issues: Number of issues opened in the last 3 months (previous 3 months)',
  now(),
  0.0,
  ip3::text
from
  issues_opened{{rnd}}
union select 'phealth,' || rg.repo_group || ',oip3' as name,
  'Issues: Number of issues opened in the last 3 months (previous 3 months)',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from issues_opened{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',oi' as name,
  'Issues: Number of issues opened in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  case i3 > ip3 when true then 'Up' else case i3 < ip3 when true then 'Down' else 'Flat' end end
from
  issues_opened{{rnd}}
union select 'phealth,' || rg.repo_group || ',oi' as name,
  'Issues: Number of issues opened in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from issues_opened{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',ci3' as name,
  'Issues: Number of issues closed in the last 3 months',
  now(),
  0.0,
  i3::text
from
  issues_closed{{rnd}}
union select 'phealth,' || rg.repo_group || ',ci3' as name,
  'Issues: Number of issues closed in the last 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from issues_closed{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',ci6' as name,
  'Issues: Number of issues closed in the last 6 months',
  now(),
  0.0,
  i6::text
from
  issues_closed{{rnd}}
union select 'phealth,' || rg.repo_group || ',ci6' as name,
  'Issues: Number of issues closed in the last 6 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from issues_closed{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',ci12' as name,
  'Issues: Number of issues closed in the last 12 months',
  now(),
  0.0,
  i12::text
from
  issues_closed{{rnd}}
union select 'phealth,' || rg.repo_group || ',ci12' as name,
  'Issues: Number of issues closed in the last 12 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from issues_closed{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',cip3' as name,
  'Issues: Number of issues closed in the last 3 months (previous 3 months)',
  now(),
  0.0,
  ip3::text
from
  issues_closed{{rnd}}
union select 'phealth,' || rg.repo_group || ',cip3' as name,
  'Issues: Number of issues closed in the last 3 months (previous 3 months)',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from issues_closed{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',ci' as name,
  'Issues: Number of issues closed in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  case i3 > ip3 when true then 'Up' else case i3 < ip3 when true then 'Down' else 'Flat' end end
from
  issues_closed{{rnd}}
union select 'phealth,' || rg.repo_group || ',ci' as name,
  'Issues: Number of issues closed in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from issues_closed{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',io2c' as name,
  'Issues: Opened to closed rate in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  case r3 < 0 or rp3 < 0 when true then '-' else case r3 > rp3 when true then 'Up' else case r3 < rp3 when true then 'Down' else 'Flat' end end end
from
  issue_ratio{{rnd}}
union select 'phealth,' || rg.repo_group || ',io2c' as name,
  'Issues: Opened to closed rate in the last 3 months vs. previous 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from issue_ratio{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || io.repo_group || ',io2c3' as name,
  'Issues: Opened to closed rate in the last 3 months',
  now(),
  0.0,
  case ic.i3 when 0 then '-' else round(io.i3::numeric / ic.i3::numeric, 2)::text end
from
  issues_opened{{rnd}} io,
  issues_closed{{rnd}} ic
where
  io.repo_group = ic.repo_group
union select 'phealth,' || rg.repo_group || ',io2c3' as name,
  'Issues: Opened to closed rate in the last 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from issues_opened{{rnd}} io, issues_closed{{rnd}} ic where io.repo_group = ic.repo_group and ic.repo_group = rg.repo_group) = 0
union select 'phealth,' || io.repo_group || ',io2cp3' as name,
  'Issues: Opened to closed rate in the last 3 months (previous 3 months)',
  now(),
  0.0,
  case ic.ip3 when 0 then '-' else round(io.ip3::numeric / ic.ip3::numeric, 2)::text end
from
  issues_opened{{rnd}} io,
  issues_closed{{rnd}} ic
where
  io.repo_group = ic.repo_group
union select 'phealth,' || rg.repo_group || ',io2cp3' as name,
  'Issues: Opened to closed rate in the last 3 months (previous 3 months)',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from issues_opened{{rnd}} io, issues_closed{{rnd}} ic where io.repo_group = ic.repo_group and ic.repo_group = rg.repo_group) = 0
union select 'phealth,' || io.repo_group || ',io2c6' as name,
  'Issues: Opened to closed rate in the last 6 months',
  now(),
  0.0,
  case ic.i6 when 0 then '-' else round(io.i6::numeric / ic.i6::numeric, 2)::text end
from
  issues_opened{{rnd}} io,
  issues_closed{{rnd}} ic
where
  io.repo_group = ic.repo_group
union select 'phealth,' || rg.repo_group || ',io2c6' as name,
  'Issues: Opened to closed rate in the last 6 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from issues_opened{{rnd}} io, issues_closed{{rnd}} ic where io.repo_group = ic.repo_group and ic.repo_group = rg.repo_group) = 0
union select 'phealth,' || io.repo_group || ',io2c12' as name,
  'Issues: Opened to closed rate in the last 12 months',
  now(),
  0.0,
  case ic.i12 when 0 then '-' else round(io.i12::numeric / ic.i12::numeric, 2)::text end
from
  issues_opened{{rnd}} io,
  issues_closed{{rnd}} ic
where
  io.repo_group = ic.repo_group
union select 'phealth,' || rg.repo_group || ',io2c12' as name,
  'Issues: Opened to closed rate in the last 12 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from issues_opened{{rnd}} io, issues_closed{{rnd}} ic where io.repo_group = ic.repo_group and ic.repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',ncontr3' as name,
  'Contributors: Number of new contributors in the last 3 months',
  now(),
  0.0,
  ncontrib3::text
from
  new3_contributors{{rnd}}
union select 'phealth,' || rg.repo_group || ',ncontr3' as name,
  'Contributors: Number of new contributors in the last 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from new3_contributors{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',ncontr6' as name,
  'Contributors: Number of new contributors in the last 6 months',
  now(),
  0.0,
  ncontrib6::text
from
  new6_contributors{{rnd}}
union select 'phealth,' || rg.repo_group || ',ncontr6' as name,
  'Contributors: Number of new contributors in the last 6 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from new6_contributors{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',ncontr12' as name,
  'Contributors: Number of new contributors in the last 12 months',
  now(),
  0.0,
  ncontrib12::text
from
  new12_contributors{{rnd}}
union select 'phealth,' || rg.repo_group || ',ncontr12' as name,
  'Contributors: Number of new contributors in the last 12 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from new12_contributors{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || repo_group || ',ncontrp3' as name,
  'Contributors: Number of new contributors in the last 3 months (last 3 months)',
  now(),
  0.0,
  ncontribp3::text
from
  new6_contributors{{rnd}}
union select 'phealth,' || rg.repo_group || ',ncontrp3' as name,
  'Contributors: Number of new contributors in the last 3 months (last 3 months)',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from new6_contributors{{rnd}} where repo_group = rg.repo_group) = 0
union select 'phealth,' || n.repo_group || ',ncontr' as name,
  'Contributors: Number of new contributors in the last 3 months vs. last 3 months',
  now(),
  0.0,
  case n.ncontrib3 > p.ncontribp3 when true then 'Up' else case n.ncontrib3 < p.ncontribp3 when true then 'Down' else 'Flat' end end
from
  new3_contributors{{rnd}} n,
  new6_contributors{{rnd}} p
where
  n.repo_group = p.repo_group
union select 'phealth,' || rg.repo_group || ',ncontr' as name,
  'Contributors: Number of new contributors in the last 3 months vs. last 3 months',
  now(),
  0.0,
  '-'
from
  repo_groups{{rnd}} rg
where
  (select count(*) from new3_contributors{{rnd}} n, new6_contributors{{rnd}} p where n.repo_group = p.repo_group and p.repo_group = rg.repo_group) = 0
union select 'phealth,' || rg.repo_group || ',topcompknact3' as name,
  'Companies: Percent of known commits pushers from top committing company (last 3 months)',
  now(),
  0.0,
  coalesce(t.top, '-')
from
  repo_groups{{rnd}} rg
left join
  top_known_actors_3{{rnd}} t
on
  rg.repo_group = t.repo_group
union select 'phealth,' || rg.repo_group || ',topcompallact3' as name,
  'Companies: Percent of all commits pushers from top committing company (last 3 months)',
  now(),
  0.0,
  coalesce(t.top, '-')
from
  repo_groups{{rnd}} rg
left join
  top_all_actors_3{{rnd}} t
on
  rg.repo_group = t.repo_group
union select 'phealth,' || rg.repo_group || ',topcompknauth3' as name,
  'Companies: Percent of known commits authors from top committing company (last 3 months)',
  now(),
  0.0,
  coalesce(t.top, '-')
from
  repo_groups{{rnd}} rg
left join
  top_known_authors_3{{rnd}} t
on
  rg.repo_group = t.repo_group
union select 'phealth,' || rg.repo_group || ',topcompallauth3' as name,
  'Companies: Percent of all commits authors from top committing company (last 3 months)',
  now(),
  0.0,
  coalesce(t.top, '-')
from
  repo_groups{{rnd}} rg
left join
  top_all_authors_3{{rnd}} t
on
  rg.repo_group = t.repo_group
union select 'phealth,' || rg.repo_group || ',topcompkncom3' as name,
  'Companies: Percent of known commits from top committing company (previous 3 months)',
  now(),
  0.0,
  coalesce(t.top, '-')
from
  repo_groups{{rnd}} rg
left join
  top_known_committers_3{{rnd}} t
on
  rg.repo_group = t.repo_group
union select 'phealth,' || rg.repo_group || ',topcompallcom3' as name,
  'Companies: Percent of all commits from top committing company (previous 3 months)',
  now(),
  0.0,
  coalesce(t.top, '-')
from
  repo_groups{{rnd}} rg
left join
  top_all_committers_3{{rnd}} t
on
  rg.repo_group = t.repo_group
union select 'phealth,' || rg.repo_group || ',topcompknact12' as name,
  'Companies: Percent of known commits pushers from top committing company (last year)',
  now(),
  0.0,
  coalesce(t.top, '-')
from
  repo_groups{{rnd}} rg
left join
  top_known_actors_12{{rnd}} t
on
  rg.repo_group = t.repo_group
union select 'phealth,' || rg.repo_group || ',topcompallact12' as name,
  'Companies: Percent of all commits pushers from top committing company (last year)',
  now(),
  0.0,
  coalesce(t.top, '-')
from
  repo_groups{{rnd}} rg
left join
  top_all_actors_12{{rnd}} t
on
  rg.repo_group = t.repo_group
union select 'phealth,' || rg.repo_group || ',topcompknauth12' as name,
  'Companies: Percent of known commits authors from top committing company (last year)',
  now(),
  0.0,
  coalesce(t.top, '-')
from
  repo_groups{{rnd}} rg
left join
  top_known_authors_12{{rnd}} t
on
  rg.repo_group = t.repo_group
union select 'phealth,' || rg.repo_group || ',topcompallauth12' as name,
  'Companies: Percent of all commits authors from top committing company (last year)',
  now(),
  0.0,
  coalesce(t.top, '-')
from
  repo_groups{{rnd}} rg
left join
  top_all_authors_12{{rnd}} t
on
  rg.repo_group = t.repo_group
union select 'phealth,' || rg.repo_group || ',topcompkncom12' as name,
  'Companies: Percent of known commits from top committing company (last year)',
  now(),
  0.0,
  coalesce(t.top, '-')
from
  repo_groups{{rnd}} rg
left join
  top_known_committers_12{{rnd}} t
on
  rg.repo_group = t.repo_group
union select 'phealth,' || rg.repo_group || ',topcompallcom12' as name,
  'Companies: Percent of all commits from top committing company (last year)',
  now(),
  0.0,
  coalesce(t.top, '-')
from
  repo_groups{{rnd}} rg
left join
  top_all_committers_12{{rnd}} t
on
  rg.repo_group = t.repo_group
;

drop table repo_groups{{rnd}};
drop table top_known_committers_12{{rnd}};
drop table top_all_committers_12{{rnd}};
drop table top_known_authors_12{{rnd}};
drop table top_all_authors_12{{rnd}};
drop table top_known_actors_12{{rnd}};
drop table top_all_actors_12{{rnd}};
drop table top_known_committers_3{{rnd}};
drop table top_all_committers_3{{rnd}};
drop table top_known_authors_3{{rnd}};
drop table top_all_authors_3{{rnd}};
drop table top_known_actors_3{{rnd}};
drop table top_all_actors_3{{rnd}};
drop table company_commits_committers_counts{{rnd}};
drop table company_commits_authors_counts{{rnd}};
drop table company_commits_actors_counts{{rnd}};
drop table known_commits_committers_counts{{rnd}};
drop table known_commits_authors_counts{{rnd}};
drop table known_commits_actors_counts{{rnd}};
drop table commits_counts{{rnd}};
drop table pr_ratio{{rnd}};
drop table react_time{{rnd}};
drop table tdiffs{{rnd}};
drop table recent_issues{{rnd}};
drop table issue_ratio{{rnd}};
drop table issues_closed{{rnd}};
drop table issues_opened{{rnd}};
drop table prs_merged{{rnd}};
drop table prs_closed{{rnd}};
drop table prs_opened{{rnd}};
drop table commits{{rnd}};
drop table new3_contributors{{rnd}};
drop table new6_contributors{{rnd}};
drop table new12_contributors{{rnd}};
drop table prev3_contributors{{rnd}};
drop table prev6_contributors{{rnd}};
drop table prev12_contributors{{rnd}};
drop table contributors{{rnd}};
drop table projects{{rnd}};
drop table skip_projects{{rnd}};
drop table strip_projects{{rnd}};
drop table suffix_projects{{rnd}};
drop table ph_push{{rnd}};
drop table ph_issues{{rnd}};
drop table ph_prs{{rnd}};
drop table ph_aff_committers{{rnd}};
drop table ph_aff_authors{{rnd}};
drop table ph_aff_actors{{rnd}};
drop table ph_commits{{rnd}};
drop table ph_base{{rnd}};
