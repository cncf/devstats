#!/bin/bash
./lfs-diff-curr.sh ./github_users.json | grep '^+' | less
