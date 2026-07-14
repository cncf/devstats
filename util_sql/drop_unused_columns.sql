alter table if exists gha_events drop column if exists public, drop column if exists forkee_id;
alter table if exists gha_payloads drop column if exists ref_type, drop column if exists master_branch, drop column if exists description, drop column if exists dup_actor_id;
alter table if exists gha_comments drop column if exists diff_hunk;
alter table if exists gha_commits drop column if exists encrypted_email;
alter table if exists gha_issues drop column if exists dupn_assignee_login;
alter table if exists gha_pull_requests drop column if exists dupn_assignee_login;
alter table if exists gha_forkees drop column if exists description, drop column if exists fork, drop column if exists created_at, drop column if exists pushed_at, drop column if exists homepage, drop column if exists size, drop column if exists has_issues, drop column if exists has_projects, drop column if exists has_downloads, drop column if exists has_wiki, drop column if exists has_pages, drop column if exists default_branch, drop column if exists public, drop column if exists language, drop column if exists organization, drop column if exists dup_actor_login, drop column if exists dup_type, drop column if exists dup_owner_login;
alter table if exists gha_branches drop column if exists label, drop column if exists ref, drop column if exists dup_type, drop column if exists dupn_forkee_name, drop column if exists dupn_user_login;
alter table if exists gha_issues_events_labels drop column if exists issue_number;
alter table if exists gha_events_commits_files drop column if exists dup_type, drop column if exists dup_created_at;

vacuum full gha_events;
vacuum full gha_payloads;
vacuum full gha_comments;
vacuum full gha_commits;
vacuum full gha_issues;
vacuum full gha_pull_requests;
vacuum full gha_forkees;
vacuum full gha_branches;
vacuum full gha_issues_events_labels;
vacuum full gha_events_commits_files;

