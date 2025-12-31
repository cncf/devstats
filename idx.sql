CREATE INDEX events_repo_name_created_at_idx ON gha_events (repo_id, dup_repo_name, created_at);

CREATE INDEX commits_repo_name_created_at_idx ON gha_commits (dup_repo_id, dup_repo_name, dup_created_at);

CREATE INDEX comments_repo_name_created_at_idx ON gha_comments (dup_repo_id, dup_repo_name, created_at);

CREATE INDEX issues_repo_created_at_issues_idx
ON gha_issues (dup_repo_id, dup_repo_name, created_at)
WHERE is_pull_request = false;

CREATE INDEX issues_repo_created_at_prs_idx
ON gha_issues (dup_repo_id, dup_repo_name, created_at)
WHERE is_pull_request = true;

CREATE INDEX pull_requests_repo_merged_at_idx
ON gha_pull_requests (dup_repo_id, dup_repo_name, merged_at)
WHERE merged_at IS NOT NULL;

