# Safe Change Checklist (Devcontainer / VS Code / Docker)

## Before risky changes (30–60 seconds)
1) Make sure you’re on the right branch:
   - git branch --show-current

2) Sync with remote and keep history clean:
   - git pull --rebase

3) Confirm working tree is clean (or intentionally saved):
   - git status

4) Create a savepoint commit (only if there are changes):
   - git add -A
   - git commit -m "WIP savepoint before changes" || echo "Nothing to commit"

5) Push and update the savepoint tag:
   - git push origin main
   - git tag -f pre-change-savepoint
   - git push -f origin pre-change-savepoint

## If things break (panic rollback)
1) Go back to the last savepoint:
   - git fetch --tags origin
   - git checkout pre-change-savepoint

2) If you want to keep working from that point:
   - git checkout -b recovery-from-savepoint

3) In VS Code: reset the container state
   - F1 → Dev Containers: Rebuild and Reopen in Container

4) Verify environment:
   - which python
   - python -m pip -V
   Expected: /app/.venv/bin/python and pip from /app/.venv/...

## When you’re done with the risky change
1) Commit with a clear message:
   - git add -A
   - git commit -m "Describe the change"

2) Push:
   - git push origin main

3) (Optional) Tag a new stable milestone:
   - git tag stable-<short-name>
   - git push origin stable-<short-name>
