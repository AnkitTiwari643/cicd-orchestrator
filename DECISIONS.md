# Decisions I owned

1. **Single `ci-cd.yml` over many workflow files:** the screenshot shows one workflow
   producing the whole fan-out graph. One file + one `orchestrate` job keeps routing
   visible and avoids condition drift across files. Reusable workflows can come later
   without changing the contract.

2. **Outputs-based gating (`needs.orchestrate.outputs.*`):** every deploy/version/sync
   job reads one boolean instead of re-implementing `github.ref` logic. One-line change
   to routing, zero drift.

3. **PRs never deploy:** `on: pull_request` jobs are test/build/validate only.
   Deploys trigger on `push` to `integration`/`main` (i.e. post-merge). No preview-env
   sprawl, no secret exposure on forks.

4. **Version bump only on `main`:** `integration` is a moving pre-release line;
   versions are cut when prod truth advances. Tag = deployable artifact identity.

5. **Auto-sync `main` → `integration`:** version commit makes `main` +1 ahead;
   sync keeps `integration` from drifting. Direct merge-push with fallback to PR
   if protection blocks bots.

6. **Environments for approvals:** `qa`/`stg` auto, `prod` requires reviewer.
   Approval nodes in the graph come from environments, not custom code.
