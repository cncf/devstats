#!/usr/bin/env bash

# DevStats shared-affiliations migration helper functions.
# Source this file from the cncf/devstats repository root:
#   source /path/to/migration-functions.sh
#   preamble devstats-test devel/all_test_dbs.txt
#
# The file intentionally does not change the caller's shell options.

KUBE_CONTEXT="${KUBE_CONTEXT:-prod}"
AFFS_DB="${AFFS_DB:-affiliations}"

preamble() {
  local ns="${1:?usage: preamble <namespace> <db-list-file>}"
  local list="${2:?usage: preamble <namespace> <db-list-file>}"
  local primary_lines primary_count

  [[ -r "$list" ]] || {
    echo "ABORT: cannot read DB list: $list" >&2
    return 1
  }

  primary_lines="$(
    kubectl --context "$KUBE_CONTEXT" -n "$ns" get pods \
      -l role=primary,type=postgres \
      -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
  )" || return 1

  primary_count="$(printf '%s\n' "$primary_lines" | sed '/^$/d' | wc -l | tr -d ' ')"
  if [[ "$primary_count" != "1" ]]; then
    echo "ABORT: expected exactly one Patroni primary in $ns, found $primary_count" >&2
    printf '%s\n' "$primary_lines" >&2
    return 1
  fi

  NS="$ns"
  LIST="$list"
  PRIMARY="$(printf '%s\n' "$primary_lines" | sed '/^$/d')"
  export NS LIST PRIMARY KUBE_CONTEXT AFFS_DB
  echo "$NS primary: $PRIMARY; DB list: $LIST"
}

_require_preamble() {
  : "${NS:?run: preamble <namespace> <db-list-file>}"
  : "${PRIMARY:?run: preamble <namespace> <db-list-file>}"
  : "${LIST:?run: preamble <namespace> <db-list-file>}"
}

pgk() {
  _require_preamble || return 1
  kubectl --context "$KUBE_CONTEXT" -n "$NS" exec "$PRIMARY" \
    -c devstats-postgres -- "$@"
}

ki() {
  _require_preamble || return 1
  kubectl --context "$KUBE_CONTEXT" -n "$NS" exec -i "$PRIMARY" \
    -c devstats-postgres -- "$@"
}

create_shared() (
  set -euo pipefail
  _require_preamble

  if [[ "$(pgk psql -X -qAt -v ON_ERROR_STOP=1 -c "select count(*) from pg_database where datname = '$AFFS_DB'")" != "0" ]]; then
    echo "ABORT: database '$AFFS_DB' already exists; do not rerun create_shared" >&2
    exit 1
  fi

  pgk psql -X -v ON_ERROR_STOP=1 -c "create database $AFFS_DB"
  pgk psql -X -v ON_ERROR_STOP=1 -c "grant all privileges on database \"$AFFS_DB\" to gha_admin"
  pgk psql -X -v ON_ERROR_STOP=1 "$AFFS_DB" -c "grant usage, create on schema public to gha_admin"
  ki psql -X -U gha_admin "$AFFS_DB" -v ON_ERROR_STOP=1 --single-transaction \
    < util_sql/affiliations_tables.sql
  ki psql -X -U gha_admin "$AFFS_DB" -v ON_ERROR_STOP=1 \
    < util_sql/country_codes.sql
  pgk psql -X -v ON_ERROR_STOP=1 "$AFFS_DB" \
    -c "grant select on all tables in schema public to ro_user, devstats_team"
  pgk psql -X -v ON_ERROR_STOP=1 devstats \
    -c "grant usage, create on schema public to gha_admin"
  ki psql -X -U gha_admin devstats -v ON_ERROR_STOP=1 \
    < util_sql/devstats_locks_table.sql
)

seed() (
  set -euo pipefail
  _require_preamble

  kubectl --context "$KUBE_CONTEXT" -n "$NS" cp "$LIST" \
    "$PRIMARY:/tmp/dbs.txt" -c devstats-postgres

  ki env AFFS_DB="$AFFS_DB" bash -s <<'REMOTE_BASH'
set -euo pipefail

psql -X -q -v ON_ERROR_STOP=1 -U gha_admin "$AFFS_DB" -c "
  drop table if exists staging_actors, staging_emails, staging_names;
  create unlogged table staging_actors (like gha_actors);
  create unlogged table staging_emails (like gha_actors_emails);
  create unlogged table staging_names (like gha_actors_names);
"

for db in $(cat /tmp/dbs.txt); do
  kind=$(psql -X -qAt -v ON_ERROR_STOP=1 "$db" -c "
    select coalesce((
      select relkind::text
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'gha_actors'
    ), '-')
  ")
  case "$kind" in
    r) ;;
    f) echo "SKIP $db (already shared)"; continue ;;
    *) echo "ABORT: $db gha_actors relkind='$kind'" >&2; exit 1 ;;
  esac

  echo "=== $db"
  psql -X -q -v ON_ERROR_STOP=1 "$db" \
    -c "\copy (select * from gha_actors) to stdout" \
    | psql -X -q -v ON_ERROR_STOP=1 -U gha_admin "$AFFS_DB" \
        -c "\copy staging_actors from stdin"
  psql -X -q -v ON_ERROR_STOP=1 "$db" \
    -c "\copy (select * from gha_actors_emails where origin = 1) to stdout" \
    | psql -X -q -v ON_ERROR_STOP=1 -U gha_admin "$AFFS_DB" \
        -c "\copy staging_emails from stdin"
  psql -X -q -v ON_ERROR_STOP=1 "$db" \
    -c "\copy (select * from gha_actors_names where origin = 1) to stdout" \
    | psql -X -q -v ON_ERROR_STOP=1 -U gha_admin "$AFFS_DB" \
        -c "\copy staging_names from stdin"
done

psql -X -v ON_ERROR_STOP=1 -U gha_admin "$AFFS_DB" <<'SQL'
insert into gha_actors(id, login, name, country_id, sex, sex_prob, tz, tz_offset, country_name, age)
select id, login, name, country_id, sex, sex_prob, tz, tz_offset, country_name, age
from (
  select s.*, row_number() over (
    partition by id, login
    order by ((name is not null and name <> '')::int + (country_id is not null and country_id <> '')::int
      + (sex is not null)::int + (sex_prob is not null)::int + (tz is not null and tz <> '')::int
      + (tz_offset is not null)::int + (country_name is not null)::int + (age is not null)::int) desc
  ) rn from staging_actors s
) x where rn = 1
on conflict (id, login) do nothing;

insert into gha_actors_emails(actor_id, email, origin)
select actor_id, email, max(origin) from staging_emails group by actor_id, email
on conflict (actor_id, email)
do update set origin = greatest(gha_actors_emails.origin, excluded.origin);

insert into gha_actors_names(actor_id, name, origin)
select actor_id, name, max(origin) from staging_names group by actor_id, name
on conflict (actor_id, name)
do update set origin = greatest(gha_actors_names.origin, excluded.origin);

drop table staging_actors, staging_emails, staging_names;
analyze gha_actors, gha_actors_emails, gha_actors_names,
        gha_actors_affiliations, gha_companies, gha_countries,
        gha_imported_shas, gha_bot_logins;
SQL
REMOTE_BASH
)

_wait_job_terminal() {
  local job="${1:?usage: _wait_job_terminal <job> <timeout-seconds>}"
  local timeout="${2:?usage: _wait_job_terminal <job> <timeout-seconds>}"
  local started="$SECONDS" succeeded failed

  while true; do
    succeeded="$(kubectl --context "$KUBE_CONTEXT" -n "$NS" get "job/$job" \
      -o jsonpath='{.status.succeeded}' 2>/dev/null || true)"
    failed="$(kubectl --context "$KUBE_CONTEXT" -n "$NS" get "job/$job" \
      -o jsonpath='{range .status.conditions[?(@.type=="Failed")]}{.status}{end}' 2>/dev/null || true)"

    if [[ "${succeeded:-0}" -ge 1 ]]; then
      return 0
    fi
    if [[ "$failed" == "True" ]]; then
      return 1
    fi
    if (( SECONDS - started >= timeout )); then
      echo "ABORT: timed out waiting for job/$job after ${timeout}s" >&2
      return 1
    fi
    sleep 10
  done
}

reconcile() (
  set -euo pipefail
  _require_preamble
  local job="${1:-affs-recon-$(date +%s)-$RANDOM}"

  kubectl --context "$KUBE_CONTEXT" -n "$NS" create job \
    --from=cronjob/devstats-affiliations-import "$job"

  if ! _wait_job_terminal "$job" 5400; then
    kubectl --context "$KUBE_CONTEXT" -n "$NS" describe "job/$job" || true
    kubectl --context "$KUBE_CONTEXT" -n "$NS" logs "job/$job" \
      --all-containers=true --tail=-1 || true
    echo "ABORT: reconciliation job failed: $job" >&2
    exit 1
  fi

  kubectl --context "$KUBE_CONTEXT" -n "$NS" logs "job/$job" \
    --all-containers=true --tail=-1
)

maps() (
  set -euo pipefail
  _require_preamble
  ki psql -X -U gha_admin "$AFFS_DB" -v ON_ERROR_STOP=1 \
    < util_sql/shared_maps.sql
)

_fdw_mode_file() {
  _require_preamble || return 1
  printf '%s\n' "${AFFS_FDW_MODE_FILE:-$HOME/.devstats-affs-fdw-mode-$NS}"
}

save_fdw_mode() {
  local mode="${1:?usage: save_fdw_mode socket|password}"
  local file
  case "$mode" in
    socket|password) ;;
    *) echo "ABORT: invalid FDW mode: $mode" >&2; return 1 ;;
  esac

  file="$(_fdw_mode_file)" || return 1
  AFFS_FDW_MODE="$mode"
  export AFFS_FDW_MODE
  printf '%s\n' "$mode" > "$file" || return 1
  chmod 600 "$file" || return 1
  echo "Saved AFFS_FDW_MODE=$mode in $file"
}

load_fdw_mode() {
  local file mode
  file="$(_fdw_mode_file)" || return 1
  [[ -r "$file" ]] || {
    echo "ABORT: FDW mode file does not exist: $file" >&2
    return 1
  }

  mode="$(tr -d '[:space:]' < "$file")"
  case "$mode" in
    socket|password) ;;
    *) echo "ABORT: invalid saved FDW mode: $mode" >&2; return 1 ;;
  esac

  AFFS_FDW_MODE="$mode"
  export AFFS_FDW_MODE
  echo "Loaded AFFS_FDW_MODE=$AFFS_FDW_MODE"
}

fdw() (
  set -euo pipefail
  _require_preamble
  local db="${1:?usage: fdw <db> [socket|password]}"
  local mode="${2:-${AFFS_FDW_MODE:-socket}}"
  local kind

  case "$mode" in
    socket|password) ;;
    *) echo "ABORT: invalid FDW mode: $mode" >&2; exit 1 ;;
  esac

  kind="$(pgk psql -X -qAt -v ON_ERROR_STOP=1 "$db" -c "
    select coalesce((
      select relkind::text
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'gha_actors'
    ), '-')
  ")"
  if [[ "$kind" == "f" ]]; then
    echo "ABORT: $db is already flipped; fdw would DROP SERVER ... CASCADE" >&2
    exit 1
  fi
  if [[ "$kind" != "r" ]]; then
    echo "ABORT: $db gha_actors relkind='$kind', expected local table 'r'" >&2
    exit 1
  fi

  if [[ "$mode" == "socket" ]]; then
    ki psql -X "$db" -v ON_ERROR_STOP=1 <<'SQL'
begin;
create extension if not exists postgres_fdw;
drop server if exists affiliations cascade;
create server affiliations foreign data wrapper postgres_fdw
  options (
    host '/var/run/postgresql',
    port '5432',
    dbname 'affiliations',
    use_remote_estimate 'true',
    fetch_size '10000'
  );
create user mapping for postgres
  server affiliations options (user 'postgres', password_required 'false');
create user mapping for gha_admin
  server affiliations options (user 'gha_admin', password_required 'false');
create user mapping for ro_user
  server affiliations options (user 'ro_user', password_required 'false');
create user mapping for devstats_team
  server affiliations options (user 'devstats_team', password_required 'false');
commit;
SQL
  else
    pgk bash -lc 'test -n "${PG_PASS:-}"' || {
      echo "ABORT: PG_PASS is not present in the PostgreSQL pod environment" >&2
      exit 1
    }
    ki psql -X "$db" -v ON_ERROR_STOP=1 <<'SQL'
\getenv affs_password PG_PASS
begin;
create extension if not exists postgres_fdw;
drop server if exists affiliations cascade;
create server affiliations foreign data wrapper postgres_fdw
  options (
    host '127.0.0.1',
    port '5432',
    dbname 'affiliations',
    use_remote_estimate 'true',
    fetch_size '10000'
  );
create user mapping for postgres
  server affiliations options (user 'gha_admin', password :'affs_password');
create user mapping for gha_admin
  server affiliations options (user 'gha_admin', password :'affs_password');
create user mapping for ro_user
  server affiliations options (user 'gha_admin', password :'affs_password');
create user mapping for devstats_team
  server affiliations options (user 'gha_admin', password :'affs_password');
commit;
\unset affs_password
SQL
  fi

  echo "$db: FDW server and mappings configured in $mode mode"
)

fdw_auth_test() (
  set -euo pipefail
  _require_preamble
  local db="${1:?usage: fdw_auth_test <db>}"

  ki psql -X "$db" -v ON_ERROR_STOP=1 <<'SQL'
begin;

create foreign table public.__affs_fdw_auth_test(
  id bigint,
  login varchar(120)
) server affiliations
  options (schema_name 'public', table_name 'gha_actors');

grant select on public.__affs_fdw_auth_test
  to gha_admin, ro_user, devstats_team;
grant insert on public.__affs_fdw_auth_test to gha_admin;

select current_user as local_role,
       (select count(*) from (
          select 1 from public.__affs_fdw_auth_test limit 1
        ) s) as rows_read;

set role gha_admin;
select current_user as local_role,
       (select count(*) from (
          select 1 from public.__affs_fdw_auth_test limit 1
        ) s) as rows_read;
insert into public.__affs_fdw_auth_test(id, login)
values (
  (-9000000000000000000 + pg_backend_pid())::bigint,
  '__fdw_auth_test_' || pg_backend_pid()::text
);
reset role;

set role ro_user;
select current_user as local_role,
       (select count(*) from (
          select 1 from public.__affs_fdw_auth_test limit 1
        ) s) as rows_read;
reset role;

set role devstats_team;
select current_user as local_role,
       (select count(*) from (
          select 1 from public.__affs_fdw_auth_test limit 1
        ) s) as rows_read;
reset role;

rollback;
SQL

  echo "$db: all four FDW mappings authenticated; gha_admin write test was rolled back"
)

_sha256_file() {
  local file="${1:?}"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
  elif command -v sha256 >/dev/null 2>&1; then
    sha256 -q "$file"
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    echo "ABORT: no local SHA-256 utility found" >&2
    return 1
  fi
}

copy_migration_sql() (
  set -euo pipefail
  _require_preamble
  local file base local_sha remote_sha

  for file in \
    util_sql/migrate_project_to_shared.sql \
    util_sql/shared_foreign_tables.sql \
    util_sql/rollback_project_from_shared.sql
  do
    [[ -r "$file" ]] || {
      echo "ABORT: cannot read $file" >&2
      exit 1
    }
    base="$(basename "$file")"
    kubectl --context "$KUBE_CONTEXT" -n "$NS" cp "$file" \
      "$PRIMARY:/tmp/$base" -c devstats-postgres
    local_sha="$(_sha256_file "$file")"
    remote_sha="$(pgk sha256sum "/tmp/$base" | awk '{print $1}')"
    [[ "$local_sha" == "$remote_sha" ]] || {
      echo "ABORT: checksum mismatch for $file" >&2
      exit 1
    }
    echo "OK: $file -> $PRIMARY:/tmp/$base ($local_sha)"
  done
)

validate_migrated_db() (
  set -euo pipefail
  _require_preamble
  local db="${1:?usage: validate_migrated_db <db>}"
  local kind foreign_tables mappings

  kind="$(pgk psql -X -qAt -v ON_ERROR_STOP=1 "$db" -c "
    select coalesce((
      select relkind::text
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'gha_actors'
    ), '-')
  ")"
  foreign_tables="$(pgk psql -X -qAt -v ON_ERROR_STOP=1 "$db" -c "
    select count(*)
    from information_schema.foreign_tables
    where foreign_table_schema = 'public'
      and foreign_server_name = 'affiliations'
  ")"
  mappings="$(pgk psql -X -qAt -v ON_ERROR_STOP=1 "$db" -c "
    select count(*) from pg_user_mappings where srvname = 'affiliations'
  ")"

  [[ "$kind" == "f" && "$foreign_tables" == "11" && "$mappings" == "4" ]] || {
    echo "ABORT: $db validation failed (kind=$kind foreign_tables=$foreign_tables mappings=$mappings)" >&2
    exit 1
  }
  echo "OK: $db migrated (11 foreign tables, 4 mappings)"
)

flip() (
  set -euo pipefail
  _require_preamble
  local db="${1:?usage: flip <db>}"

  pgk test -r /tmp/migrate_project_to_shared.sql
  pgk test -r /tmp/shared_foreign_tables.sql
  pgk test -r /tmp/rollback_project_from_shared.sql
  pgk psql -X "$db" --single-transaction -v ON_ERROR_STOP=1 \
    -f /tmp/migrate_project_to_shared.sql
  validate_migrated_db "$db"
)

rollback_db() (
  set -euo pipefail
  _require_preamble
  local db="${1:?usage: rollback_db <db>}"
  pgk psql -X "$db" --single-transaction -v ON_ERROR_STOP=1 \
    -f /tmp/rollback_project_from_shared.sql
)

flip_all_dbs() (
  set -euo pipefail
  _require_preamble
  local db kind

  load_fdw_mode
  copy_migration_sql

  while IFS= read -r db; do
    [[ -n "$db" ]] || continue
    kind="$(pgk psql -X -qAt -v ON_ERROR_STOP=1 "$db" -c "
      select coalesce((
        select relkind::text
        from pg_class c
        join pg_namespace n on n.oid = c.relnamespace
        where n.nspname = 'public' and c.relname = 'gha_actors'
      ), '-')
    ")"

    if [[ "$kind" == "f" ]]; then
      validate_migrated_db "$db"
      continue
    fi
    if [[ "$kind" != "r" ]]; then
      echo "ABORT: $db gha_actors relkind='$kind'" >&2
      exit 1
    fi

    echo "=== $db"
    fdw "$db" "$AFFS_FDW_MODE"
    flip "$db"
  done < <(tr '[:space:]' '\n' < "$LIST" | sed '/^$/d')
)

sanity_db() (
  set -euo pipefail
  _require_preamble
  local db="${1:?usage: sanity_db <db>}"
  local shared_actors project_actors missing_actors actor_id

  validate_migrated_db "$db"

  shared_actors="$(pgk psql -X -qAt -v ON_ERROR_STOP=1 "$AFFS_DB" -c 'select count(*) from gha_actors')"
  project_actors="$(pgk psql -X -qAt -v ON_ERROR_STOP=1 "$db" -c 'select count(*) from gha_actors')"
  echo "shared gha_actors=$shared_actors; $db gha_actors=$project_actors"
  [[ "$shared_actors" == "$project_actors" ]] || {
    echo "ABORT: project foreign-table count does not match shared table" >&2
    exit 1
  }

  pgk psql -X -v ON_ERROR_STOP=1 -P pager=off "$db" -c "
    select foreign_table_name, foreign_server_name
    from information_schema.foreign_tables
    where foreign_table_schema = 'public'
      and foreign_server_name = 'affiliations'
    order by foreign_table_name;
  "

  missing_actors="$(pgk psql -X -qAt -v ON_ERROR_STOP=1 "$db" -c "
    select count(*)
    from gha_events e
    where e.actor_id is not null
      and not exists (select 1 from gha_actors a where a.id = e.actor_id)
  ")"
  echo "$db gha_events actor IDs missing from shared gha_actors: $missing_actors"
  [[ "$missing_actors" == "0" ]] || {
    echo "ABORT: actor coverage check failed" >&2
    exit 1
  }

  actor_id="$(pgk psql -X -qAt -v ON_ERROR_STOP=1 "$db" -c "
    select actor_id from gha_events where actor_id is not null order by created_at desc limit 1
  ")"
  if [[ -n "$actor_id" ]]; then
    echo "--- Direct foreign lookup; expect a Foreign Scan and a Remote SQL line with id=$actor_id"
    pgk psql -X -v ON_ERROR_STOP=1 -P pager=off "$db" -c "
      explain (verbose, costs off)
      select id, login from gha_actors where id = $actor_id;
    "
  fi

  echo "--- Local gha_events x foreign gha_actors join; expect at least one Foreign Scan/Remote SQL line"
  pgk psql -X -v ON_ERROR_STOP=1 -P pager=off "$db" -c "
    explain (verbose, costs off)
    select count(*)
    from gha_events e
    join gha_actors a on a.id = e.actor_id
    where e.created_at > now() - interval '7 days';
  "
)

patch_project_cronjobs() (
  set -euo pipefail
  _require_preamble
  local project="${1:?usage: patch_project_cronjobs <project-key>}"
  local sync_cj="devstats-$project"
  local affs_cj="devstats-affiliations-$project"

  kubectl --context "$KUBE_CONTEXT" -n "$NS" get cronjob "$sync_cj" "$affs_cj" >/dev/null

  kubectl --context "$KUBE_CONTEXT" -n "$NS" set env "cronjob/$sync_cj" \
    GHA2DB_AFFILIATIONS_DB="$AFFS_DB"

  kubectl --context "$KUBE_CONTEXT" -n "$NS" set env "cronjob/$affs_cj" \
    GHA2DB_AFFILIATIONS_DB="$AFFS_DB" \
    GHA2DB_CHECK_IMPORTED_SHA= \
    GET_AFFS_FILES=

  echo "--- $sync_cj environment"
  kubectl --context "$KUBE_CONTEXT" -n "$NS" set env "cronjob/$sync_cj" --list
  echo "--- $affs_cj environment"
  kubectl --context "$KUBE_CONTEXT" -n "$NS" set env "cronjob/$affs_cj" --list
)

wait_project_jobs_drained() (
  set -euo pipefail
  _require_preamble
  local project="${1:?usage: wait_project_jobs_drained <project-key>}"
  local sync_cj="devstats-$project"
  local affs_cj="devstats-affiliations-$project"
  local active

  while true; do
    active="$(
      kubectl --context "$KUBE_CONTEXT" -n "$NS" get jobs -o json \
        | jq -r --arg sync "$sync_cj" --arg affs "$affs_cj" '
            .items[]
            | select((.status.active // 0) > 0)
            | select(any(.metadata.ownerReferences[]?;
                .kind == "CronJob" and (.name == $sync or .name == $affs)))
            | .metadata.name
          '
    )"
    [[ -z "$active" ]] && break
    echo "waiting for active jobs:"
    printf '%s\n' "$active"
    sleep 15
  done
  echo "$project jobs drained"
)

run_cronjob_once() (
  set -euo pipefail
  _require_preamble
  local cronjob="${1:?usage: run_cronjob_once <cronjob> [job-name]}"
  local job="${2:-${cronjob}-manual-$(date +%s)}"
  local pod log_pid

  kubectl --context "$KUBE_CONTEXT" -n "$NS" create job \
    --from="cronjob/$cronjob" "$job"
  kubectl --context "$KUBE_CONTEXT" -n "$NS" wait \
    --for=create pod -l "job-name=$job" --timeout=5m
  pod="$(kubectl --context "$KUBE_CONTEXT" -n "$NS" get pod \
    -l "job-name=$job" -o jsonpath='{.items[0].metadata.name}')"

  kubectl --context "$KUBE_CONTEXT" -n "$NS" logs -f "$pod" \
    --all-containers=true &
  log_pid=$!

  if ! _wait_job_terminal "$job" 93600; then
    wait "$log_pid" || true
    kubectl --context "$KUBE_CONTEXT" -n "$NS" describe "job/$job" || true
    kubectl --context "$KUBE_CONTEXT" -n "$NS" logs "job/$job" \
      --all-containers=true --tail=-1 || true
    echo "ABORT: job failed or timed out: $job" >&2
    exit 1
  fi

  wait "$log_pid" || true
  echo "OK: job/$job completed"
)

show_project_logs() (
  set -euo pipefail
  _require_preamble
  local project="${1:?usage: show_project_logs <project-key> [interval]}"
  local interval="${2:-2 hours}"

  pgk psql -X -v ON_ERROR_STOP=1 -P pager=off devstats -c "
    select dt, prog, proj, run_dt, msg
    from gha_logs
    where proj = '$project'
      and dt >= now() - interval '$interval'
    order by id desc
    limit 250;
  "

  echo "--- Error-like messages"
  pgk psql -X -v ON_ERROR_STOP=1 -P pager=off devstats -c "
    select dt, prog, proj, run_dt, msg
    from gha_logs
    where proj = '$project'
      and dt >= now() - interval '$interval'
      and coalesce(msg, '') ~* '(error|fatal|panic)'
    order by id desc;
  "
)
