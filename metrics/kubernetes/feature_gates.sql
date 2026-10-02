with feature_gate_mentions as (
  select 
    i.id,
    i.created_at,
    i.milestone_id,
    i.body,
    i.title,
    'issue' as type,
    -- Extract feature gate names from issue body and title
    -- Pattern matches: FeatureGateName, feature-gate-name, or similar patterns
    array(
      select distinct unnest(
        regexp_split_to_array(
          regexp_replace(
            coalesce(i.body, '') || ' ' || coalesce(i.title, ''),
            '(?i)\b(feature[- ]?gate[s]?[:\s]*|gate[s]?[:\s]*)?([A-Za-z][A-Za-z0-9]*(?:[A-Z][a-z]*)*|[a-z]+(?:-[a-z]+)*)\b',
            '\2',
            'g'
          ),
          '\s+'
        )
      )
      where length(unnest(regexp_split_to_array(
        regexp_replace(
          coalesce(i.body, '') || ' ' || coalesce(i.title, ''),
          '(?i)\b(feature[- ]?gate[s]?[:\s]*|gate[s]?[:\s]*)?([A-Za-z][A-Za-z0-9]*(?:[A-Z][a-z]*)*|[a-z]+(?:-[a-z]+)*)\b',
          '\2',
          'g'
        ),
        '\s+'
      ))) > 2
    ) as feature_gates,
    -- Extract state information (alpha, beta, stable/GA, deprecated)
    case 
      when i.body ~* '\b(alpha|experimental)\b' or i.title ~* '\b(alpha|experimental)\b' then 'alpha'
      when i.body ~* '\bbeta\b' or i.title ~* '\bbeta\b' then 'beta'
      when i.body ~* '\b(stable|GA|general[- ]?availability)\b' or i.title ~* '\b(stable|GA|general[- ]?availability)\b' then 'GA'
      when i.body ~* '\b(deprecated|removed|removal)\b' or i.title ~* '\b(deprecated|removed|removal)\b' then 'deprecated'
      else 'unknown'
    end as state
  from 
    gha_issues i
  where 
    i.created_at >= '{{from}}'
    and i.created_at < '{{to}}'
    and (
      i.body ~* '\b(feature[- ]?gate|gate)[s]?\b' 
      or i.title ~* '\b(feature[- ]?gate|gate)[s]?\b'
    )
  
  union all
  
  select 
    pr.id,
    pr.created_at,
    pr.milestone_id,
    pr.body,
    pr.title,
    'pr' as type,
    -- Extract feature gate names from PR body and title
    array(
      select distinct unnest(
        regexp_split_to_array(
          regexp_replace(
            coalesce(pr.body, '') || ' ' || coalesce(pr.title, ''),
            '(?i)\b(feature[- ]?gate[s]?[:\s]*|gate[s]?[:\s]*)?([A-Za-z][A-Za-z0-9]*(?:[A-Z][a-z]*)*|[a-z]+(?:-[a-z]+)*)\b',
            '\2',
            'g'
          ),
          '\s+'
        )
      )
      where length(unnest(regexp_split_to_array(
        regexp_replace(
          coalesce(pr.body, '') || ' ' || coalesce(pr.title, ''),
          '(?i)\b(feature[- ]?gate[s]?[:\s]*|gate[s]?[:\s]*)?([A-Za-z][A-Za-z0-9]*(?:[A-Z][a-z]*)*|[a-z]+(?:-[a-z]+)*)\b',
          '\2',
          'g'
        ),
        '\s+'
      ))) > 2
    ) as feature_gates,
    -- Extract state information
    case 
      when pr.body ~* '\b(alpha|experimental)\b' or pr.title ~* '\b(alpha|experimental)\b' then 'alpha'
      when pr.body ~* '\bbeta\b' or pr.title ~* '\bbeta\b' then 'beta'
      when pr.body ~* '\b(stable|GA|general[- ]?availability)\b' or pr.title ~* '\b(stable|GA|general[- ]?availability)\b' then 'GA'
      when pr.body ~* '\b(deprecated|removed|removal)\b' or pr.title ~* '\b(deprecated|removed|removal)\b' then 'deprecated'
      else 'unknown'
    end as state
  from 
    gha_pull_requests pr
  where 
    pr.created_at >= '{{from}}'
    and pr.created_at < '{{to}}'
    and (
      pr.body ~* '\b(feature[- ]?gate|gate)[s]?\b' 
      or pr.title ~* '\b(feature[- ]?gate|gate)[s]?\b'
    )
),
feature_gate_labels as (
  select 
    fgm.id,
    fgm.created_at,
    fgm.milestone_id,
    fgm.type,
    fgm.feature_gates,
    fgm.state,
    -- Extract SIG from labels
    coalesce(
      (
        select 
          regexp_replace(iel.label_name, '^sig/', '', 'g')
        from 
          gha_issues_events_labels iel 
        where 
          iel.issue_id = fgm.id 
          and iel.label_name ~ '^sig/'
        limit 1
      ),
      'unknown'
    ) as sig
  from 
    feature_gate_mentions fgm
),
pr_feature_gates as (
  select 
    fgl.id,
    fgl.created_at,
    fgl.milestone_id,
    fgl.type,
    fgl.state,
    fgl.sig,
    unnest(fgl.feature_gates) as feature_gate
  from 
    feature_gate_labels fgl
  where 
    array_length(fgl.feature_gates, 1) > 0
),
pr_feature_gate_labels as (
  select 
    pfg.*,
    -- Extract release version from milestone
    coalesce(
      (
        select 
          regexp_replace(m.title, '^v?(.+)$', 'v\1', 'g')
        from 
          gha_milestones m 
        where 
          m.id = pfg.milestone_id
          and m.title ~ '^v?1\.\d+'
      ),
      'unknown'
    ) as release
  from 
    pr_feature_gates pfg
)
select 
  -- Time 
  '{{to}}'::timestamp as time,
  -- Series name: SIG_State_Release (e.g., sig-api-machinery_beta_v1.30)
  case 
    when pfgl.sig = 'All' and pfgl.state = 'All' and pfgl.release = 'All' then 'All_All_All'
    when pfgl.sig = 'All' and pfgl.state = 'All' then concat('All_All_', pfgl.release)
    when pfgl.sig = 'All' and pfgl.release = 'All' then concat('All_', pfgl.state, '_All')
    when pfgl.state = 'All' and pfgl.release = 'All' then concat(pfgl.sig, '_All_All')
    when pfgl.sig = 'All' then concat('All_', pfgl.state, '_', pfgl.release)
    when pfgl.state = 'All' then concat(pfgl.sig, '_All_', pfgl.release)
    when pfgl.release = 'All' then concat(pfgl.sig, '_', pfgl.state, '_All')
    else concat(pfgl.sig, '_', pfgl.state, '_', pfgl.release)
  end as series,
  -- Count of feature gates
  count(distinct pfgl.feature_gate) as value
from 
  pr_feature_gate_labels pfgl
group by 
  rollup(pfgl.sig, pfgl.state, pfgl.release)
having 
  count(distinct pfgl.feature_gate) > 0

union all

-- Add time series for aggregated views
select 
  '{{to}}'::timestamp as time,
  'All_All_All' as series,
  count(distinct pfgl.feature_gate) as value
from 
  pr_feature_gate_labels pfgl

union all

select 
  '{{to}}'::timestamp as time,
  concat('All_', pfgl.state, '_All') as series,
  count(distinct pfgl.feature_gate) as value
from 
  pr_feature_gate_labels pfgl
group by 
  pfgl.state

union all

select 
  '{{to}}'::timestamp as time,
  concat(pfgl.sig, '_All_All') as series,
  count(distinct pfgl.feature_gate) as value
from 
  pr_feature_gate_labels pfgl
group by 
  pfgl.sig

union all

select 
  '{{to}}'::timestamp as time,
  concat('All_All_', pfgl.release) as series,
  count(distinct pfgl.feature_gate) as value
from 
  pr_feature_gate_labels pfgl
group by 
  pfgl.release

union all

select 
  '{{to}}'::timestamp as time,
  concat('All_', pfgl.state, '_', pfgl.release) as series,
  count(distinct pfgl.feature_gate) as value
from 
  pr_feature_gate_labels pfgl
group by 
  pfgl.state, pfgl.release

union all

select 
  '{{to}}'::timestamp as time,
  concat(pfgl.sig, '_All_', pfgl.release) as series,
  count(distinct pfgl.feature_gate) as value
from 
  pr_feature_gate_labels pfgl
group by 
  pfgl.sig, pfgl.release

union all

select 
  '{{to}}'::timestamp as time,
  concat(pfgl.sig, '_', pfgl.state, '_All') as series,
  count(distinct pfgl.feature_gate) as value
from 
  pr_feature_gate_labels pfgl
group by 
  pfgl.sig, pfgl.state