# Excluding bots

- You can put excluding bots partial `{{exclude_bots}}` anywhere in the metric SQL.
- You should put exclude bots partial inside parentheses like for example: `(lower(actor_login) {{exclude_bots}})`.
- `{{exclude_bots}}` will be replaced with the contents of the [util_sql/exclude_bots.sql](https://github.com/cncf/devstats/blob/master/util_sql/exclude_bots.sql). This file [util_sql/only_bots.sql](https://github.com/cncf/devstats/blob/master/util_sql/only_bots.sql) is used to list bots alone.
- Currently it is defined as `not like all(array[...])` with exact (lower case) bot logins followed by `like` wildcard patterns, for example: `not like all(array['googlebot', 'coveralls', 'rktbot', 'coreosbot', 'web-flow', 'copilot%', 'dependabot%', 'k8s-%', '%-bot', '%bot-%', '%-robot', '%[%bot]%', '%-jenkins', '%ci%bot', '%-testing', 'codecov%', '%automat%', '%agent', '% bot'])` - see the file for the full list (141 patterns, last audited against live `allprj` data and every per-project database on 2026-09-13 - see `BOTS.md`).
- The same list is also stored in the `gha_bot_logins` table (filled by `util_sql/exclude_bots_table_insert.sql`, see `structure`), so ad-hoc queries can use `not ilike all(select pattern from gha_bot_logins)` ([util_sql/exclude_bots_table.sql](https://github.com/cncf/devstats/blob/master/util_sql/exclude_bots_table.sql)).
- To add a bot edit `util_sql/exclude_bots.sql` and run `./devel/regen_bot_lists.py`, see [BOTS.md](../BOTS.md).
- Most actor related metrics use this.
