#!/usr/bin/env bash
# Integrate ~/.dotfile shell files without replacing distro-owned startup files.
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DIR="${HOME:?HOME is not set}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME_DIR/.dotfile-backups/shell-entry-$STAMP}"
BEGIN="# >>> dotfiles managed block >>>"
END="# <<< dotfiles managed block <<<"
DRY_RUN=0
REPLACE=0

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        --replace) REPLACE=1 ;;
        *) printf "Usage: %s [--dry-run] [--replace]\n" "$0" >&2; exit 2 ;;
    esac
done

add_block() {
    local target="$1"
    local source_rel="$2"

    if [ -f "$target" ] && grep -qF "$BEGIN" "$target"; then
        printf "already integrated: %s\n" "$target"
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        printf "would integrate: %s -> %s\n" "$target" "$source_rel"
        return 0
    fi

    mkdir -p "$(dirname "$target")"
    touch "$target"
    {
        printf '\n%s\n' "$BEGIN"
        printf 'if [ -f "$HOME/.dotfile/%s" ]; then\n' "$source_rel"
        printf '    . "$HOME/.dotfile/%s"\n' "$source_rel"
        printf 'fi\n'
        printf '%s\n' "$END"
    } >> "$target"
    printf "integrated: %s -> %s\n" "$target" "$source_rel"
}

replace_with_block() {
    local target="$1"
    local source_rel="$2"
    local backup="$BACKUP_ROOT/${target#"$HOME_DIR"/}"

    if [ "$DRY_RUN" -eq 1 ]; then
        printf "would replace with shim: %s -> %s\n" "$target" "$source_rel"
        return 0
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$(dirname "$backup")"
        mv "$target" "$backup"
        printf "backed up: %s -> %s\n" "$target" "$backup"
    fi
    printf '# Managed by ~/.dotfile. Local changes should go in the repository.\n' > "$target"
    add_block "$target" "$source_rel"
}

if [ "$REPLACE" -eq 1 ]; then
    replace_with_block "$HOME_DIR/.bashrc" "shell/bashrc"
    replace_with_block "$HOME_DIR/.bash_profile" "shell/bash_profile"
    replace_with_block "$HOME_DIR/.profile" "shell/profile"
    if [ -e "$HOME_DIR/.zshrc" ]; then
        replace_with_block "$HOME_DIR/.zshrc" "shell/zshrc"
    fi
else
    add_block "$HOME_DIR/.bashrc" "shell/bashrc"
    add_block "$HOME_DIR/.bash_profile" "shell/bash_profile"
    add_block "$HOME_DIR/.profile" "shell/profile"
    if [ -e "$HOME_DIR/.zshrc" ]; then
        add_block "$HOME_DIR/.zshrc" "shell/zshrc"
    fi
fi

if [ -d "$BACKUP_ROOT" ]; then
    printf "\nBackups: %s\n" "$BACKUP_ROOT"
fi
