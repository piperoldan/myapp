#!/usr/bin/env bash
set -euo pipefail

echo "== Savepoint: sync, snapshot, push =="
git pull --rebase
git status

git add -A
git commit -m "WIP savepoint before changes" || echo "Nothing to commit"

git push origin main

git tag -f pre-change-savepoint
git push -f origin pre-change-savepoint

git show -s --oneline --decorate HEAD
echo "== Done =="
