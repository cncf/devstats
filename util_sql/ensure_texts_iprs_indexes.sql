-- Canonical index set for gha_texts and gha_issues_pull_requests, kept in
-- sync with structure.go. Safe to run anytime (create index if not exists).
-- Used as the final step of devel/remove_db_dups.sh so databases deduped by
-- older script versions (which silently dropped indexes) are healed too.
create index if not exists texts_event_id_idx on gha_texts(event_id);
create index if not exists texts_created_at_idx on gha_texts(created_at);
create index if not exists texts_actor_id_idx on gha_texts(actor_id);
create index if not exists texts_actor_login_idx on gha_texts(actor_login);
create index if not exists texts_repo_id_idx on gha_texts(repo_id);
create index if not exists texts_repo_name_idx on gha_texts(repo_name);
create index if not exists texts_type_idx on gha_texts(type);
create index if not exists texts_lower_actor_login_idx on gha_texts(lower(actor_login));
create index if not exists issues_pull_requests_issue_id_idx on gha_issues_pull_requests(issue_id);
create index if not exists issues_pull_requests_pull_request_id_idx on gha_issues_pull_requests(pull_request_id);
create index if not exists issues_pull_requests_number_idx on gha_issues_pull_requests(number);
create index if not exists issues_pull_requests_repo_id_idx on gha_issues_pull_requests(repo_id);
create index if not exists issues_pull_requests_repo_name_idx on gha_issues_pull_requests(repo_name);
create index if not exists issues_pull_requests_created_at_idx on gha_issues_pull_requests(created_at);
