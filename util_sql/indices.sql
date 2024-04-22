create index issues_id_idx on gha_issues(id);
create index issues_number_idx on gha_issues(number);
create index pull_requests_number_idx on gha_pull_requests(number);
create index pull_requests_id_idx on gha_pull_requests(id);
create index comments_id_idx on gha_comments(id);
create index milestones_id_idx on gha_milestones(id);
