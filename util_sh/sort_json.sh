#!/bin/bash
set -euo pipefail
if [ -z "${1:-}" ]
then
  echo "$0: please provide a file name as a 1st arg"
  exit 1
fi
# Create temp file in current directory to keep mv atomic within same filesystem
out="$(mktemp ./XXXXXX)"
# Sort JSON keys deterministically and write back atomically
jq -S . "$1" > "$out" && mv "$out" "$1"
