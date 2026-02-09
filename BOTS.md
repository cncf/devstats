# Bots

If you find a new bot include it in:

- `cncf/devstats`:
  - `util_sql/exclude_bots.sql`.
  - `util_sql/exclude_bots_table_insert.sql`.
  - `util_sql/only_bots.sql`
  - `structure.sql`.
- Optionally:
  - `util_sql/actors.sql`.
  - `util_sql/top_actors.sql`.
  - `util_sql/top_unknown_committers_without_email.sql`.
  - `util_sql/top_unknown_contributors_without_email.sql`.
- `vim util_sql/exclude_bots_table.sql util_sql/exclude_bots_table_insert.sql ./util_sql/actors.sql util_sql/top_unknown_committers_without_email.sql ./util_sql/top_unknown_contributors_without_email.sql util_sql/top_actors.sql util_sql/exclude_bots.sql structure.sql util_sql/only_bots.sql util_sql/only_bots_table.sql util_sql/bus_and_elaphan_factors.sql`.

- `cncf/devstats-example`:
  - `util_sql/exclude_bots.sql`.

- `LF-Engineering/dev-analytics-json2hat`:
  - `json2hat.go`: `func updateBots`.

- `cncf/velocity`:
    - `BigQuery/velocity_*.sql` (especially `BigQuery/velocity_standard_query.sql` and `*condition*.sql` files).
