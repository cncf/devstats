#!/bin/bash
set -euo pipefail

# Usage:
#   git_commits.sh <repo_path> <sha1> [sha2 ... shaN]
#
# Output (one record per commit):
#   sha,b64(author_name),b64(author_email),b64(committer_name),b64(committer_email),b64(message);
#
# Fields separated by ','; records separated by ';'.

if [ $# -lt 2 ]; then
  exit 0
fi

REPO="$1"
shift

if [ -z "${REPO}" ]; then
  echo "missing repo path" >&2
  exit 2
fi
if [ ! -d "${REPO}/.git" ]; then
  echo "repo path is not a git repo: ${REPO}" >&2
  exit 2
fi
if [ "$#" -lt 1 ]; then
  exit 0
fi

b64() {
  if base64 -w 0 </dev/null >/dev/null 2>&1; then
    base64 -w 0
  else
    base64 | tr -d '\n'
  fi
}

shas=("$@")
git -C "${REPO}" log -z --no-walk --format='%H%x00%an%x00%ae%x00%cn%x00%ce%x00%B' "${shas[@]}" |
while IFS= read -r -d '' SHA; do
  IFS= read -r -d '' AN || AN=""
  IFS= read -r -d '' AE || AE=""
  IFS= read -r -d '' CN || CN=""
  IFS= read -r -d '' CE || CE=""
  IFS= read -r -d '' MSG || MSG=""

  printf "%s," "${SHA}"
  printf "%s," "$(printf "%s" "${AN}" | b64)"
  printf "%s," "$(printf "%s" "${AE}" | b64)"
  printf "%s," "$(printf "%s" "${CN}" | b64)"
  printf "%s," "$(printf "%s" "${CE}" | b64)"
  printf "%s;" "$(printf "%s" "${MSG}" | b64)"
done

printf '\n'

