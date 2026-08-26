-- Uses CREATE TABLE AS (parallel-eligible SELECT DISTINCT) instead of
-- CREATE TABLE (LIKE ...) + INSERT ... SELECT DISTINCT, because the SELECT
-- feeding an INSERT can never use a parallel plan, while CTAS can.
-- NOT NULL constraints (the only thing bare LIKE copied that CTAS does not)
-- are re-applied after the rename, so the final table state - including
-- auto-generated constraint names like <table>_<column>_not_null - is
-- identical to the previous version of this script.
set work_mem = '2GB';
create table {{table}}_temp as select distinct * from {{table}};
do $$
declare
  nn text;
begin
  select string_agg(format('alter column %I set not null', column_name), ', ')
    into nn
    from information_schema.columns
   where table_schema = 'public' and table_name = '{{table}}' and is_nullable = 'NO';
  execute 'drop table {{table}}';
  execute 'alter table {{table}}_temp rename to {{table}}';
  if nn is not null then
    execute 'alter table {{table}} ' || nn;
  end if;
end $$;
alter table {{table}} owner to gha_admin;
