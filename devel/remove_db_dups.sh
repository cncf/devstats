#!/bin/bash
GHA2DB_LOCAL=1 runq util_sql/remove_dups.sql {{table}} gha_issues_pull_requests || exit 1
GHA2DB_LOCAL=1 runq util_sql/remove_dups.sql {{table}} gha_texts || exit 2
GHA2DB_LOCAL=1 runq util_sql/ensure_texts_iprs_indexes.sql || exit 3
