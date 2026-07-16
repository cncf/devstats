-- Run: psql <projdb> --single-transaction -v ON_ERROR_STOP=1 -f util_sql/rollback_project_from_shared.sql
drop foreign table if exists gha_actors;
drop foreign table if exists gha_actors_emails;
drop foreign table if exists gha_actors_names;
drop foreign table if exists gha_companies;
drop foreign table if exists gha_actors_affiliations;
drop foreign table if exists gha_countries;
drop foreign table if exists gha_bot_logins;
drop foreign table if exists gha_map_name_to_login;
drop foreign table if exists gha_map_login_to_id;
drop foreign table if exists gha_map_id_to_login;
drop foreign table if exists gha_map_actor_email;

alter table gha_actors_pre_fdw rename to gha_actors;
alter table gha_actors_emails_pre_fdw rename to gha_actors_emails;
alter table gha_actors_names_pre_fdw rename to gha_actors_names;
alter table gha_companies_pre_fdw rename to gha_companies;
alter table gha_actors_affiliations_pre_fdw rename to gha_actors_affiliations;
alter table gha_countries_pre_fdw rename to gha_countries;
alter table gha_imported_shas_pre_fdw rename to gha_imported_shas;
alter table gha_bot_logins_pre_fdw rename to gha_bot_logins;
