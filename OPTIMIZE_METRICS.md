# Optimizing metrics

- Add explain analyze to the metric, for example `` vim /path/to/metric.sql ``, add `` explain (analyze, costs, verbose, buffers) `` on top.
- Run: `` [NODE=2] [DB=allprj] ./util_sh/run_sql.sh /path/to/metric.sql {{n}} 1 {{from}} '2024-04-01' {{to}} '2024-04-08' > /path/to/metric.sql.plan ``.
- Actual query being executed on the database is saved as `` /path/to/query.sql.runq ``.
- You can just execute query via `` [NODE=2] [DB=allprj] ./util_sh/run_sql.sh /path/to/metric.sql {{n}} 1 {{from}} '2024-04-01' {{to}} '2024-04-08' `` but if you want to do this, then don't add `` explain ... `` part.
- You can translate query (replace `` {{params}} `` inside query with their actual values) via `` ./util_sh/runq.sh /root/con3.sql [{{param1}} 'value 1' [ {{param2}} 'Val2' ] ] `` to see what is generated.
- Finally analyze explaing/plan via: `` TOP=10 ./util_rb/analyze.rb /path/to/query.sql.plan 'actual time,cost,loops' ``.
