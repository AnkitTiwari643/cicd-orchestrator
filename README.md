# CI/CD Orchestrator — branch-gated deploys with auto version + sync

![CI/CD](https://github.com/AnkitTiwari643/cicd-orchestrator/actions/workflows/ci-cd.yml/badge.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

> Owner: AnkitTiwari643 — single `ci-cd.yml` orchestrator that decides which jobs run on what condition.
> Mirrors the enterprise graph in the reference screenshot: select workflow → test matrix → build → PR validation → artifacts → env-gated deploys → post-deploy.

## Branch → environment matrix (the contract)

| Event | QA | STG | PROD | Version bump | Sync `integration` |
|---|---|---|---|---|---|
| PR (any) | ❌ | ❌ | ❌ | ❌ | ❌ (runs: test, build, validate-pr) |
| Push `integration` | ✅ | ✅ | ❌ | ❌ | ❌ |
| Push `main` | ✅ | ✅ | ✅ (approval) | ✅ | ✅ (`main` → `integration`) |

## Merge policy (enforced in `validate-pr` + branch protection)

- Into `integration`: only `feature/*`, `bugfix/*`, `hotfix/*`
- Into `main`: only `integration` and `hotfix/*`
- Anything else fails the PR in <1 min with a clear message.

## Flow

```
PR opened/sync  → orchestrate → test (matrix 18/20) → build → validate-pr → STOP (no deploy)
Push integration → orchestrate → test → build → publish artifacts → deploy QA + STG → post-deploy smoke
Push main        → orchestrate → test → build → version-up (tag vX.Y.Z, main +1) → publish → deploy QA+STG → deploy PROD (approval) → sync integration (main→integration) → post-deploy
```

## Why an orchestrator job first

One `orchestrate` job computes `is_pr / is_push_integration / is_push_main` outputs.
Every downstream job uses `if: needs.orchestrate.outputs.<x> == 'true'` instead of duplicating
branch/event conditions. Reviewers read the routing in one place; deploy jobs stay dumb.
This is what produces the fan-out graph in the screenshot.

## Run locally

```bash
npm --prefix app install
make test        # node --test, coverage
make build       # docker build
make version-show
```

## Repo setup after push (required to make gates real)

1. Settings → Environments: create `qa`, `stg`, `prod`. On `prod` add Required reviewers (yourself).
2. Settings → Branches → rule for `integration`: require PR + status checks (`validate-pr`, `build`), restrict source branches by policy in workflow.
3. Settings → Branches → rule for `main`: require PR + status checks, allow only `integration` + `hotfix/*` (workflow enforces, protection requires PR).
4. No secrets needed for demo (deploys are simulated + smoke-tested). For real AWS, add `AWS_ROLE_ARN` and swap the `run:` deploy steps for your deploy actions.

## Files

- `.github/workflows/ci-cd.yml` — thin orchestrator: routing outputs + gated calls
- `.github/workflows/reusable-test.yml` — test matrix (Node 18/20)
- `.github/workflows/reusable-coverage.yml` — coverage report artifact
- `.github/workflows/reusable-build.yml` — Docker build validation
- `.github/workflows/reusable-validate-pr.yml` — merge policy + PR hygiene (PR only)
- `.github/workflows/reusable-version.yml` — patch bump + tag (push `main` only)
- `.github/workflows/reusable-publish.yml` — release artifact
- `.github/workflows/reusable-deploy-qa.yml` — QA deploy (`environment: qa` gate lives here)
- `.github/workflows/reusable-deploy-stg.yml` — STG deploy (`environment: stg` gate lives here)
- `.github/workflows/reusable-deploy-prod.yml` — PROD deploy (`environment: prod` approval lives here)
- `.github/workflows/reusable-sync.yml` — merge `main` back into `integration`
- `.github/workflows/reusable-smoke.yml` — post-deploy health check
- `scripts/bump-version.sh` — patch bump, commit, tag (runs only on `main`)
- `BRANCHING.md` — merge policy + version/sync explanation
- `DECISIONS.md` — why single workflow + outputs over many files
