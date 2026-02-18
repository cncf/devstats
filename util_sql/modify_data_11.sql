alter table gha_commits add column if not exists origin smallint not null default 0;
