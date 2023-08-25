with org as (
  select
    row_number() over (
      partition by
        r.repo_group
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) desc
    ) as row_number,
    r.repo_group,
    'contributions' as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) as cnt
  from
    gha_events e,
    gha_repos r,
    gha_actors_affiliations aa
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and e.actor_id = aa.actor_id
    and aa.dt_from <= e.created_at
    and aa.dt_to > e.created_at
    and e.type in (
      'IssuesEvent', 'PullRequestEvent', 'PushEvent',
      'PullRequestReviewCommentEvent', 'IssueCommentEvent',
      'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
    )
    and aa.company_name != ''
  group by
    r.repo_group,
    aa.company_name
  union select
    row_number() over (
      order by
        round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) desc
    ) as row_number,
    'All',
    'contributions' as metric,
    'org' as tp,
    aa.company_name as name,
    round(hll_cardinality(hll_add_agg(hll_hash_bigint(e.id)))) as cnt
  from
    gha_events e,
    gha_repos r,
    gha_actors_affiliations aa
  where
    r.name = e.dup_repo_name
    and r.id = e.repo_id
    and e.actor_id = aa.actor_id
    and aa.dt_from <= e.created_at
    and aa.dt_to > e.created_at
    and e.type in (
      'IssuesEvent', 'PullRequestEvent', 'PushEvent',
      'PullRequestReviewCommentEvent', 'IssueCommentEvent',
      'CommitCommentEvent', 'ForkEvent', 'WatchEvent', 'PullRequestReviewEvent'
    )
    and aa.company_name != ''
  group by
    aa.company_name
), rg as (
  select
    row_number,
    repo_group,
    metric,
    tp,
    name,
    cnt
  from
    org
  order by
    metric,
    tp,
    repo_group,
    cnt desc
), all_rg as (
  select
    repo_group,
    metric,
    tp,
    sum(cnt) as cnt
  from
    rg
  group by
    repo_group,
    metric,
    tp
), cum_rg as (
  select
    r.repo_group,
    r.metric,
    r.tp,
    r.row_number,
    r.cnt,
    r.name,
    100.0 * r.cnt / (case ar.cnt when 0 then 1 else ar.cnt end) as percent,
    (100.0 * sum(r.cnt) over (
      partition by
        r.repo_group,
        r.metric,
        r.tp
      order by
        r.row_number asc
      rows between unbounded preceding and current row
    )) / (case r.cnt when 0 then 1 else ar.cnt end) as cumulative_percent
  from
    rg r
  inner join
    all_rg ar
  on
    r.repo_group = ar.repo_group
    and r.metric = ar.metric
    and r.tp = ar.tp
  order by
    r.repo_group,
    r.metric,
    r.tp,
    r.row_number
), bf as (
  select
    repo_group,
    metric,
    tp,
    min(row_number) as bus_factor,
    min(cumulative_percent) as percent,
    max(row_number) - min(row_number) as others_count,
    100.0 - min(cumulative_percent) as others_percent
  from
    cum_rg
  where
    cumulative_percent > 50.0
  group by
    repo_group,
    metric,
    tp
), bfc as (
  select
    b.repo_group,
    b.metric,
    b.tp,
    string_agg(cr.name, ', ') over (
      partition by
        b.repo_group,
        b.metric,
        b.tp
      order by
        cr.row_number
    ) as companies
  from
    bf b,
    cum_rg cr
  where
    cr.repo_group = b.repo_group
    and cr.metric = b.metric
    and cr.tp = b.tp
    and cr.row_number <= b.bus_factor
    and cr.row_number <= 10
), bfa as (
  select
    b.repo_group,
    b.metric,
    b.tp,
    b.bus_factor,
    b.percent,
    max(c.companies) as companies,
    b.others_count,
    b.others_percent
  from
    bf b,
    bfc c
  where
    b.repo_group = c.repo_group
    and b.metric = c.metric
    and b.tp = c.tp
  group by
    b.repo_group,
    b.metric,
    b.tp,
    b.bus_factor,
    b.percent,
    b.others_count,
    b.others_percent
), top as (
  select
    repo_group,
    metric,
    tp,
    max(row_number) as top_n,
    max(cumulative_percent) as top_percent,
    100.0 - max(cumulative_percent) as non_top_percent
  from
    cum_rg
  where
    row_number <= 10
  group by
    repo_group,
    metric,
    tp
), topc as (
  select
    t.repo_group,
    t.metric,
    t.tp,
    string_agg(cr.name, ', ') over (
      partition by
        t.repo_group,
        t.metric,
        t.tp
      order by
        cr.row_number
    ) as companies
  from
    top t,
    cum_rg cr
  where
    cr.repo_group = t.repo_group
    and cr.metric = t.metric
    and cr.tp = t.tp
    and cr.row_number <= t.top_n
), topa as (
  select
    t.repo_group,
    t.metric,
    t.tp,
    t.top_n,
    t.top_percent,
    max(c.companies) as companies,
    t.non_top_percent
  from
    top t,
    topc c
  where
    t.repo_group = c.repo_group
    and t.metric = c.metric
    and t.tp = c.tp
  group by
    t.repo_group,
    t.metric,
    t.tp,
    t.top_n,
    t.top_percent,
    t.non_top_percent
), final as (
  select
    b.repo_group,
    b.metric,
    b.tp,
    b.bus_factor,
    b.percent as bus_factor_percent,
    b.companies as bus_factor_companies,
    b.others_count,
    b.others_percent,
    t.top_n,
    t.top_percent,
    t.companies as top_companies,
    (b.bus_factor + b.others_count) - t.top_n as non_top_count,
    t.non_top_percent
  from
    bfa b,
    topa t
  where
    b.repo_group = t.repo_group
    and b.metric = t.metric
    and b.tp = t.tp
)
select * from final;
