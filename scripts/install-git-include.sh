#!/usr/bin/env bash
# Add a managed include block to ~/.gitconfig without replacing machine identity.
set -euo pipefail

TARGET="${HOME:?HOME is not set}/.gitconfig"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.dotfile-backups/git-include-$(date +%Y%m%d-%H%M%S)}"
BEGIN="# >>> dotfiles managed include >>>"
END="# <<< dotfiles managed include <<<"
DRY_RUN=0
REPLACE=0

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        --replace) REPLACE=1 ;;
        *) printf "Usage: %s [--dry-run] [--replace]\n" "$0" >&2; exit 2 ;;
    esac
done

if [ "$REPLACE" -eq 1 ] && { [ -e "$TARGET" ] || [ -L "$TARGET" ]; }; then
    if [ "$DRY_RUN" -eq 1 ]; then
        printf "would replace with include shim: %s\n" "$TARGET"
        exit 0
    fi
    mkdir -p "$BACKUP_ROOT"
    mv "$TARGET" "$BACKUP_ROOT/gitconfig"
    printf '# Machine-local Git config. Shared settings are included from ~/.dotfile.\n' > "$TARGET"
fi

if [ -f "$TARGET" ] && grep -qF "$BEGIN" "$TARGET"; then
    echo "already integrated: $TARGET"
    exit 0
fi

if [ "$DRY_RUN" -eq 1 ]; then
    printf "would integrate: %s\n" "$TARGET"
    exit 0
fi

touch "$TARGET"
{
    printf '\n# >>> dotfiles managed include >>>\n'
    printf '[include]\n'
    printf '    path = %s\n' "$HOME/.dotfile/git/gitconfig"
    printf '# <<< dotfiles managed include <<<\n'
} >> "$TARGET"
printf "integrated: %s\n" "$TARGET"
