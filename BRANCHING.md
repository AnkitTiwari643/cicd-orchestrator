# Branching contract

Permanent branches: `main` (prod truth), `integration` (QA/STG truth).

## Allowed merge sources

- → `integration`: `feature/<desc>`, `bugfix/<desc>`, `hotfix/<desc>`
- → `main`: `integration`, `hotfix/<desc>`

Direct pushes to `main`/`integration` should be blocked by branch protection;
the workflow below assumes pushes happen via merge and treats `push` as "release".

## Versioning (main only)

`scripts/bump-version.sh` bumps patch in `VERSION` (e.g. `1.4.2` → `1.4.3`),
commits `chore(release): v1.4.3`, and tags `v1.4.3`. This makes `main`
exactly one commit ahead of `integration`.

## Sync (main → integration)

`sync-integration` job runs only on `push: main` after versioning.
It merges `main` into `integration` and pushes. If `integration` protection
blocks direct pushes, replace the push step with a `gh pr create`
from `main` → `integration` (comment in workflow shows how).

## Examples

```bash
git checkout -b feature/PD-1234/poller
# ... work, push, PR → integration (tests + build + validate-pr run, no deploy)
# merge → push on integration → QA + STG deploy

git checkout integration && git pull
git checkout -b hotfix/PD-9999/crash
# ... push, PR → main allowed (hotfix) → merge → QA+STG+PROD + version + sync
```
