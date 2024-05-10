#!/bin/bash
if [ ! -z "$VERBOSE" ]
then
  echo "GHA2DB_ABSOLUTE=1 GHA2DB_DEBUG=-1 GHA2DB_DRY_RUN=1 /data/go/src/github.com/cncf/devstatscode/runq \"${1}\" {{exclude_bots}} \"cat /data/go/src/github.com/cncf/devstats/util_sql/exclude_bots.sql\" \"${@:2}\""
fi
# GHA2DB_ABSOLUTE=1 GHA2DB_DEBUG=-1 GHA2DB_DRY_RUN=1 ../devstatscode/runq "${1}" {{exclude_bots}} "$(cat /data/go/src/github.com/cncf/devstats/util_sql/exclude_bots.sql)" "${@:2}"
GHA2DB_ABSOLUTE=1 GHA2DB_DEBUG=-1 GHA2DB_DRY_RUN=1 /data/go/src/github.com/cncf/devstatscode/runq "${1}" {{exclude_bots}} "$(cat /data/go/src/github.com/cncf/devstats/util_sql/exclude_bots.sql)" "${@:2}"
