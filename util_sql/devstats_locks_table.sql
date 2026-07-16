create table if not exists gha_locks(
  name text not null,
  owner text not null,
  dt timestamp not null default now(),
  primary key(name)
);
