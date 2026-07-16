#!/bin/bash
# AFFS_FDW_USE_PASSWORD=1 (use TCP 127.0.0.1 + gha_admin/PG_PASS mappings instead of the default local socket + password_required=false)
# AFFS_FDW_SOCKET_DIR=dir (socket directory for the default variant, default /var/run/postgresql)
if [ -z "$GHA2DB_AFFILIATIONS_DB" ]
then
  exit 0
fi
if [ -z "$1" ]
then
  echo "$0: need project database name argument"
  exit 1
fi
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to set PG_PASS to run this script"
  exit 2
fi
db=$1
adb="${GHA2DB_AFFILIATIONS_DB}"
port="${PG_PORT:-5432}"
au="${PG_ADMIN_USER:-postgres}"
PG_USER="$au" ./devel/db.sh psql "$db" -c "create extension if not exists postgres_fdw" || exit 3
PG_USER="$au" ./devel/db.sh psql "$db" -c "drop server if exists affiliations cascade" || exit 4
if [ -z "$AFFS_FDW_USE_PASSWORD" ]
then
  sdir="${AFFS_FDW_SOCKET_DIR:-/var/run/postgresql}"
  PG_USER="$au" ./devel/db.sh psql "$db" -c "create server affiliations foreign data wrapper postgres_fdw options (host '$sdir', port '$port', dbname '$adb', use_remote_estimate 'true', fetch_size '10000')" || exit 5
  PG_USER="$au" ./devel/db.sh psql "$db" -c "create user mapping for postgres server affiliations options (user 'postgres', password_required 'false')" || exit 6
  PG_USER="$au" ./devel/db.sh psql "$db" -c "create user mapping for gha_admin server affiliations options (user 'gha_admin', password_required 'false')" || exit 7
  PG_USER="$au" ./devel/db.sh psql "$db" -c "create user mapping for ro_user server affiliations options (user 'ro_user', password_required 'false')" || exit 8
  PG_USER="$au" ./devel/db.sh psql "$db" -c "create user mapping for devstats_team server affiliations options (user 'devstats_team', password_required 'false')" || exit 9
else
  PG_USER="$au" ./devel/db.sh psql "$db" -c "create server affiliations foreign data wrapper postgres_fdw options (host '127.0.0.1', port '$port', dbname '$adb', use_remote_estimate 'true', fetch_size '10000')" || exit 10
  PG_USER="$au" ./devel/db.sh psql "$db" -c "create user mapping for postgres server affiliations options (user 'gha_admin', password '$PG_PASS')" || exit 11
  PG_USER="$au" ./devel/db.sh psql "$db" -c "create user mapping for gha_admin server affiliations options (user 'gha_admin', password '$PG_PASS')" || exit 12
  PG_USER="$au" ./devel/db.sh psql "$db" -c "create user mapping for ro_user server affiliations options (user 'gha_admin', password '$PG_PASS')" || exit 13
  PG_USER="$au" ./devel/db.sh psql "$db" -c "create user mapping for devstats_team server affiliations options (user 'gha_admin', password '$PG_PASS')" || exit 14
fi
PG_USER="$au" ./devel/db.sh psql "$db" --single-transaction -v ON_ERROR_STOP=1 -f util_sql/shared_foreign_tables.sql || exit 15
echo "$0: $db: shared affiliations FDW configured (server 'affiliations' -> DB '$adb')"
