select
  time,
  round(hll_cardinality(hll_union_agg("Kubernetes"))) as "Kubernetes",
  round(hll_cardinality(hll_union_agg("CNCF"))) as "CNCF"
from
  sprjcntr
where
  period = 'y'
  and series like 'prjcnt%rcommitters'
group by
  time
order by
  time
