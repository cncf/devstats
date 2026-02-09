#!/bin/bash
if [ -z "$1" ]
then
  echo "Argument required: path to call git-reset and the git-pull"
  exit 1
fi

cd "$1" || exit 2
git fetch origin || exit 3
DEFAULT_REF="$(git symbolic-ref -q refs/remotes/origin/HEAD || true)"
if [ -n "$DEFAULT_REF" ]
then
  git reset --hard "$DEFAULT_REF" || exit 4
else
  git reset --hard origin/master || git reset --hard origin/main || exit 5
fi
git pull || exit 6
