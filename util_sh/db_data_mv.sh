#!/bin/bash
# Safely move a PostgreSQL data directory to /storage/psql and replace it with a symlink.
# Improvements:
# - Strict mode and validation to prevent accidental deletions when $1 is empty or invalid
# - Quote all paths and guard rm with '--'
# - Create destination parent directory when needed
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <data_dir_name_or_path>" >&2
  exit 1
fi

src="$1"
# Ensure source exists and is a directory
if [ -z "$src" ] || [ ! -d "$src" ]; then
  echo "$0: source directory '$src' does not exist or is not a directory" >&2
  exit 2
fi

# Compute destination path; preserve provided relative/absolute subpath under /storage/psql
# Example: src='pgdata'  -> dest='/storage/psql/pgdata'
#          src='var/lib/pg' -> dest='/storage/psql/var/lib/pg'
dest="/storage/psql/$src"

# Create destination parent directories if missing
parent_dir="$(dirname "$dest")"
mkdir -p "$parent_dir"

# Do not overwrite an existing destination unintentionally
if [ -e "$dest" ]; then
  echo "$0: destination '$dest' already exists; aborting to avoid data loss" >&2
  exit 3
fi

# Copy data recursively, preserving attributes
cp -a -v -- "$src" "$dest"

# Remove original directory and create symlink pointing to the new location
rm -rf -- "$src"
ln -s "$dest" "$src"

# Adjust ownership/permissions on the destination tree
chown -R postgres "$dest"
chgrp -R postgres "$dest"
chmod -R go+rx "$dest"
