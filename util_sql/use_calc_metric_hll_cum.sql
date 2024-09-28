with dates as (
  select
    distinct time
  from
    sprjcntr
  where
    period = 'q'
)
select
  d.time,
  round(hll_cardinality(hll_union_agg(s."Kubernetes"))) as "Kubernetes",
  round(hll_cardinality(hll_union_agg(s."CNCF"))) as "CNCF"
from
  sprjcntr s
inner join
  dates d
on
  s.time <= d.time
where
  s.period = 'q'
  -- and s.series like 'prjcntr%rcommitters'
  and s.series like any(array['%unitedstatesrcommitters', '%chinarcommitters', '%germanyrcommitters', '%polandrcommitters'])
group by
  d.time
order by
  d.time
