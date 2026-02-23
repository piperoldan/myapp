#!/usr/bin/env bash
set -euo pipefail

echo "== Savepoint: snapshot, sync, push =="

# 1. Show current state
git status

# 2. Snapshot local changes first (safe)
git add -A
git commit -m "WIP savepoint $(date '+%Y-%m-%d %H:%M:%S')" || echo "Nothing to commit"

# 3. Sync with remote safely
git pull --rebase

# 4. Push main
git push origin main

# 5. Update panic-button tag
git tag -f pre-change-savepoint
git push -f origin pre-change-savepoint

# 6. Confirmation
git show -s --oneline --decorate HEAD
echo "== Savepoint complete and locked =="
