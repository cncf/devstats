select
  schemaname || '.' || relname as table,
  pg_size_pretty(pg_total_relation_size(relid)) as total_size,
  pg_size_pretty(pg_relation_size(relid)) as table_size,
  pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) as index_size
from
  pg_catalog.pg_statio_user_tables
order by
  pg_total_relation_size(relid) desc
limit
  20
;
