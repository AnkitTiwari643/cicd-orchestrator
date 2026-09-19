#!/usr/bin/env bash
# Patch-bump VERSION, commit, and tag. Runs only on push to main (see workflow).
set -euo pipefail
CUR=$(cat VERSION | tr -d ' \n')
IFS='.' read -r MAJ MIN PAT <<< "$CUR"
NEXT="$MAJ.$MIN.$((PAT + 1))"
echo "$NEXT" > VERSION
git config user.name "${GIT_USER:-AnkitTiwari643}"
git config user.email "${GIT_EMAIL:-ankitkumar.26.ak94@gmail.com}"
git add VERSION
git commit -m "chore(release): v$NEXT" || echo "nothing to commit"
git tag "v$NEXT" || true
echo "Bumped $CUR -> $NEXT"
