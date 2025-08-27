#!/usr/bin/env bash
# Sync 5.4-dev from 'upstream' into your local branch and push to 'origin'.
# Usage: ./sync-5.4-dev.sh [--force] [--merge] [--rebase]
# Default is fast-forward only (no merge commits). Use --merge or --rebase to allow divergent histories.
set -euo pipefail

BRANCH="5.4-dev"

force=false
mode="ff"   # ff | merge | rebase

for arg in "$@"; do
  case "$arg" in
    --force) force=true ;;
    --merge) mode="merge" ;;
    --rebase) mode="rebase" ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

# Ensure we're inside a git work tree
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Not inside a Git repository. cd into your repo first." >&2
  exit 1
fi

# Check remotes
if ! git remote get-url upstream >/dev/null 2>&1; then
  echo "❌ Remote 'upstream' not configured." >&2
  exit 1
fi
if ! git remote get-url origin >/dev/null 2>&1; then
  echo "❌ Remote 'origin' not configured." >&2
  exit 1
fi

# Ensure clean working tree unless --force
if ! $force; then
  if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Working tree is dirty. Commit/stash or rerun with --force." >&2
    exit 1
  fi
fi

echo "➡️  Fetching from remotes…"
git fetch --prune upstream "${BRANCH}"
git fetch --prune origin   "${BRANCH}"

# Ensure local branch exists and switch to it
if git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
  git switch "${BRANCH}"
else
  echo "ℹ️  Creating local branch ${BRANCH} tracking upstream/${BRANCH}"
  git switch -c "${BRANCH}" --track "upstream/${BRANCH}" || true
fi

echo "➡️  Syncing local ${BRANCH} with upstream/${BRANCH} (mode=${mode})…"
case "$mode" in
  ff)
    # Fast-forward only; fails if histories diverged
    git merge --ff-only "upstream/${BRANCH}"
    ;;
  merge)
    # Allow a merge commit if necessary
    git merge --no-edit "upstream/${BRANCH}"
    ;;
  rebase)
    git rebase "upstream/${BRANCH}"
    ;;
esac

echo "➡️  Pushing ${BRANCH} to origin…"
git push origin "${BRANCH}"

echo "✅ Done. Branch ${BRANCH} is now in sync with upstream and pushed to origin."
