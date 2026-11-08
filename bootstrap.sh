#!/usr/bin/env bash
# Safe first-run setup. App configs are backed up by link.sh before linking.
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

"$REPO_DIR/link.sh" --dry-run
printf '\nApply the links above? Running bootstrap will back up conflicting files.\n'
"$REPO_DIR/link.sh"
"$REPO_DIR/scripts/install-shell-entry.sh"
"$REPO_DIR/scripts/install-git-include.sh"
"$REPO_DIR/scripts/install-fonts.sh"

printf '\nBootstrap complete.\n'
printf 'Vim remains independently managed under ~/.vim.\n'
printf 'Review package lists under %s/packages/ for system dependencies.\n' "$REPO_DIR"
