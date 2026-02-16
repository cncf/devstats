ALTER TABLE gha_commits_roles DROP CONSTRAINT IF EXISTS gha_commits_roles_pkey;
ALTER TABLE gha_commits_roles ADD PRIMARY KEY (sha, event_id, role, actor_email);

