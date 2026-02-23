#!/usr/bin/env bash
set -euo pipefail

echo "== PANIC RESTORE: back to last savepoint =="

git fetch --tags origin
git reset --hard pre-change-savepoint

echo ""
echo "Now do this in VS Code:"
echo "  F1 → Dev Containers: Rebuild and Reopen in Container"
echo ""
echo "Verify in the container terminal:"
echo "  which python"
echo "  python -m pip -V"
echo ""

git show -s --oneline --decorate HEAD
