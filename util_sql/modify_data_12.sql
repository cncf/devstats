alter table gha_commits add column if not exists inserted_at timestamp without time zone default now();
