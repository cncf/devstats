-- Run: psql <projdb> --single-transaction -v ON_ERROR_STOP=1 -f util_sql/migrate_project_to_shared.sql
set local lock_timeout = '15s';

alter table gha_actors rename to gha_actors_pre_fdw;
alter table gha_actors_emails rename to gha_actors_emails_pre_fdw;
alter table gha_actors_names rename to gha_actors_names_pre_fdw;
alter table gha_companies rename to gha_companies_pre_fdw;
alter table gha_actors_affiliations rename to gha_actors_affiliations_pre_fdw;
alter table gha_countries rename to gha_countries_pre_fdw;
alter table gha_imported_shas rename to gha_imported_shas_pre_fdw;
alter table gha_bot_logins rename to gha_bot_logins_pre_fdw;

\ir shared_foreign_tables.sql

do $$
begin
  if (select count(*) from gha_actors) = 0 then
    raise exception 'shared gha_actors is empty or unreachable';
  end if;
  if (select count(*) from gha_actors_affiliations) = 0 then
    raise exception 'shared gha_actors_affiliations is empty or unreachable';
  end if;
end $$;
