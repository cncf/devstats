create table if not exists gha_actors(
  id bigint not null,
  login varchar(120) not null,
  name varchar(120),
  country_id varchar(2),
  sex varchar(1),
  sex_prob double precision,
  tz varchar(40),
  tz_offset int,
  country_name text,
  age int,
  primary key(id, login)
);
create index if not exists actors_id_idx on gha_actors(id);
create index if not exists actors_login_idx on gha_actors(login);
create index if not exists actors_lower_login_idx on gha_actors(lower(login));
create index if not exists actors_name_idx on gha_actors(name);
create index if not exists actors_country_id_idx on gha_actors(country_id);
create index if not exists actors_sex_idx on gha_actors(sex);
create index if not exists actors_sex_prob_idx on gha_actors(sex_prob);
create index if not exists actors_tz_idx on gha_actors(tz);
create index if not exists actors_tz_offset on gha_actors(tz_offset);
create index if not exists actors_country_name_idx on gha_actors(country_name);
create index if not exists actors_age_idx on gha_actors(age);

create table if not exists gha_actors_emails(
  actor_id bigint not null,
  email varchar(120) not null,
  origin smallint not null default 0,
  primary key(actor_id, email)
);
create index if not exists actors_emails_actor_id_idx on gha_actors_emails(actor_id);
create index if not exists actors_emails_email_idx on gha_actors_emails(email);

create table if not exists gha_actors_names(
  actor_id bigint not null,
  name varchar(120) not null,
  origin smallint not null default 0,
  primary key(actor_id, name)
);
create index if not exists actors_names_actor_id_idx on gha_actors_names(actor_id);
create index if not exists actors_names_name_idx on gha_actors_names(name);

create table if not exists gha_companies(
  name varchar(160) not null,
  primary key(name)
);

create table if not exists gha_actors_affiliations(
  actor_id bigint not null,
  company_name varchar(160) not null,
  original_company_name varchar(160) not null,
  dt_from timestamp not null,
  dt_to timestamp not null,
  source varchar(30) not null default '',
  primary key(actor_id, company_name, dt_from, dt_to)
);
create index if not exists actors_affiliations_actor_id_idx on gha_actors_affiliations(actor_id);
create index if not exists actors_affiliations_company_name_idx on gha_actors_affiliations(company_name);
create index if not exists actors_affiliations_original_company_name_idx on gha_actors_affiliations(original_company_name);
create index if not exists actors_affiliations_dt_from_idx on gha_actors_affiliations(dt_from);
create index if not exists actors_affiliations_dt_to_idx on gha_actors_affiliations(dt_to);
create index if not exists actors_affiliations_source_idx on gha_actors_affiliations(source);
create index if not exists actors_affiliations_actor_from_to_idx on gha_actors_affiliations(actor_id, dt_from, dt_to);

create table if not exists gha_countries(
  code varchar(2) not null,
  name text not null,
  primary key(code)
);
create index if not exists countries_name_idx on gha_countries(name);

create table if not exists gha_imported_shas(
  sha text not null,
  dt timestamp not null default now(),
  primary key(sha)
);

create table if not exists gha_bot_logins(
  pattern text primary key
);
create index if not exists gha_bot_logins_pattern_idx on gha_bot_logins(pattern);

create table if not exists gha_map_name_to_login(
  name varchar(120) not null,
  login varchar(120) not null,
  primary key(name)
);

create table if not exists gha_map_login_to_id(
  login varchar(120) not null,
  id bigint not null,
  primary key(login)
);

create table if not exists gha_map_id_to_login(
  id bigint not null,
  login varchar(120) not null,
  primary key(id)
);

create table if not exists gha_map_actor_email(
  actor_id bigint not null,
  email varchar(120) not null,
  primary key(actor_id)
);
