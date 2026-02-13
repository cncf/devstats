#!/bin/bash
set -euo pipefail

# Usage:
#   git_commits_range.sh <repo_path> <before_sha> <head_sha> <skip> <limit>
#
# Outputs:
#   One SHA per line (max <limit>), newest->oldest.
#

if [ $# -lt 3 ]; then
  exit 0
fi

REPO="$1"
BEFOR="${2:-}"
HEAD="${3:-}"
SKIP="${4:-0}"
LIMIT="${5:-1000}"

ZERO="0000000000000000000000000000000000000000"

if [ -z "${HEAD}" ] || [ "${HEAD}" = "${ZERO}" ]; then
  exit 0
fi

if [ -z "${BEFOR}" ] || [ "${BEFOR}" = "${ZERO}" ]; then
  git -C "${REPO}" cat-file -e "${HEAD}^{commit}" 2>/dev/null || exit 0
  git -C "${REPO}" rev-list --max-count="${LIMIT}" --skip="${SKIP}" "${HEAD}"
else
  git -C "${REPO}" cat-file -e "${HEAD}^{commit}" 2>/dev/null || exit 0
  git -C "${REPO}" cat-file -e "${BEFOR}^{commit}" 2>/dev/null || exit 0
  git -C "${REPO}" rev-list --max-count="${LIMIT}" --skip="${SKIP}" "${BEFOR}..${HEAD}"
fi
