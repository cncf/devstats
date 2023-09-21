# `gha_repo_groups` table

- This table holds repository groups definitions.
- One repo can belong to multiple repository groups (key is `(id, name, repo_group)`) and one repository group cna have multiple repositories (obviously).
- This table is a copy of `gha_repos` table (with `id, name, alias, repo_group, org_id, org_login` columns) but it additionally has `repo_group` column in its PK - so allows the same repo to be a part of multiple repository groups.
- Other details are the same as `gha_repos` table.

# Columns

- `id`: GitHub repository ID.
- `name`: GitHub repository name, can change in time, but ID remains the same then.
- `alias`: Artificial column, updated by specific per-project scripts. Usually used to keep the same name for the same repo, for entire repo name change history.
- `repo_group`: Artificial column, updated by specific per-project scripts.
- `org_id`: GitHub organization ID (can be null) see [gha_orgs](https://github.com/cncf/devstats/blob/master/docs/tables/gha_orgs.md).
- `org_login`: GitHub organization name duplicated from `gha_orgs` table (can be null). This can be organization name or GitHub username.
