-- In-place duplicate removal: DELETE keeps exactly one row (arbitrary ctid)
-- per group of fully identical rows - the same result set as the previous
-- CREATE TABLE AS SELECT DISTINCT + swap approach, but:
--  * never drops the table, so indexes, grants, NOT NULL constraints, owner
--    and statistics are never lost (older versions of this script silently
--    dropped indexes and grants on every run - that is how allprj ended up
--    with unindexed gha_texts / gha_issues_pull_requests),
--  * takes no ACCESS EXCLUSIVE lock - the table stays fully readable and
--    writable for the whole duration (plain row DELETE locking only),
--  * benchmarked ~4x faster than rebuild+reindex on a 14.4M rows copy of
--    allprj gha_texts with ~10% duplicates injected (64s vs 5m18s, and the
--    rebuild variant additionally holds the exclusive lock for ~2 minutes
--    while indexes are recreated).
-- GROUP BY treats NULLs as equal, exactly like SELECT DISTINCT did, so
-- fully identical rows containing NULLs are deduplicated the same way.
-- Space freed by deleted tuples is reclaimed by autovacuum.
set work_mem = '2GB';
do $$
declare
  cols text;
begin
  select string_agg(quote_ident(column_name), ', ' order by ordinal_position)
    into cols
    from information_schema.columns
   where table_schema = 'public' and table_name = '{{table}}';
  execute format(
    'delete from {{table}} where ctid in (select unnest((array_agg(ctid))[2:]) from {{table}} group by %s having count(*) > 1)',
    cols
  );
end $$;
analyze {{table}};
