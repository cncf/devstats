drop foreign table if exists gha_actors;
create foreign table gha_actors(
  id bigint not null,
  login varchar(120) not null,
  name varchar(120),
  country_id varchar(2),
  sex varchar(1),
  sex_prob double precision,
  tz varchar(40),
  tz_offset int,
  country_name text,
  age int
) server affiliations options (schema_name 'public', table_name 'gha_actors');

drop foreign table if exists gha_actors_emails;
create foreign table gha_actors_emails(
  actor_id bigint not null,
  email varchar(120) not null,
  origin smallint not null default 0
) server affiliations options (schema_name 'public', table_name 'gha_actors_emails');

drop foreign table if exists gha_actors_names;
create foreign table gha_actors_names(
  actor_id bigint not null,
  name varchar(120) not null,
  origin smallint not null default 0
) server affiliations options (schema_name 'public', table_name 'gha_actors_names');

drop foreign table if exists gha_companies;
create foreign table gha_companies(
  name varchar(160) not null
) server affiliations options (schema_name 'public', table_name 'gha_companies');

drop foreign table if exists gha_actors_affiliations;
create foreign table gha_actors_affiliations(
  actor_id bigint not null,
  company_name varchar(160) not null,
  original_company_name varchar(160) not null,
  dt_from timestamp not null,
  dt_to timestamp not null,
  source varchar(30) not null default ''
) server affiliations options (schema_name 'public', table_name 'gha_actors_affiliations');

drop foreign table if exists gha_countries;
create foreign table gha_countries(
  code varchar(2) not null,
  name text not null
) server affiliations options (schema_name 'public', table_name 'gha_countries');

drop foreign table if exists gha_bot_logins;
create foreign table gha_bot_logins(
  pattern text not null
) server affiliations options (schema_name 'public', table_name 'gha_bot_logins');

drop foreign table if exists gha_map_name_to_login;
create foreign table gha_map_name_to_login(
  name varchar(120) not null,
  login varchar(120) not null
) server affiliations options (schema_name 'public', table_name 'gha_map_name_to_login');

drop foreign table if exists gha_map_login_to_id;
create foreign table gha_map_login_to_id(
  login varchar(120) not null,
  id bigint not null
) server affiliations options (schema_name 'public', table_name 'gha_map_login_to_id');

drop foreign table if exists gha_map_id_to_login;
create foreign table gha_map_id_to_login(
  id bigint not null,
  login varchar(120) not null
) server affiliations options (schema_name 'public', table_name 'gha_map_id_to_login');

drop foreign table if exists gha_map_actor_email;
create foreign table gha_map_actor_email(
  actor_id bigint not null,
  email varchar(120) not null
) server affiliations options (schema_name 'public', table_name 'gha_map_actor_email');

grant select on gha_actors, gha_actors_emails, gha_actors_names, gha_companies, gha_actors_affiliations, gha_countries, gha_bot_logins, gha_map_name_to_login, gha_map_login_to_id, gha_map_id_to_login, gha_map_actor_email to ro_user;
grant select on gha_actors, gha_actors_emails, gha_actors_names, gha_companies, gha_actors_affiliations, gha_countries, gha_bot_logins, gha_map_name_to_login, gha_map_login_to_id, gha_map_id_to_login, gha_map_actor_email to devstats_team;
grant select, insert, update, delete on gha_actors, gha_actors_emails, gha_actors_names, gha_companies, gha_actors_affiliations, gha_countries, gha_bot_logins, gha_map_name_to_login, gha_map_login_to_id, gha_map_id_to_login, gha_map_actor_email to gha_admin;
