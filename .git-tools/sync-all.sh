#!/usr/bin/env bash
# Sync all relevant branches (5.3-dev, 5.4-dev, 6.0-dev) from upstream and push to origin.
# Any flags you pass (e.g., --merge, --rebase, --force) are forwarded to each script.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$DIR/sync-5.3-dev.sh" "$@"
"$DIR/sync-5.4-dev.sh" "$@"
"$DIR/sync-6.0-dev.sh" "$@"

echo "✅ All branches synced."
