#!/usr/bin/env bash
# Link the managed dotfiles from this repository into $HOME.
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:?HOME is not set}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME_DIR/.dotfile-backups/$STAMP}"
DRY_RUN=0

if [ "${1:-}" = "--dry-run" ]; then
    DRY_RUN=1
elif [ "$#" -gt 0 ]; then
    printf "Usage: %s [--dry-run]\n" "$0" >&2
    exit 2
fi

link_path() {
    local source="$1"
    local target="$2"
    local backup="$BACKUP_ROOT/${target#"$HOME_DIR"/}"

    if [ ! -e "$source" ]; then
        printf "missing source: %s\n" "$source" >&2
        return 1
    fi

    if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$source")" ]; then
        printf "already linked: %s -> %s\n" "$target" "$source"
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        if [ -e "$target" ] || [ -L "$target" ]; then
            printf "would back up: %s -> %s\n" "$target" "$backup"
        fi
        printf "would link: %s -> %s\n" "$target" "$source"
        return 0
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$(dirname "$backup")"
        mv "$target" "$backup"
        printf "backed up: %s -> %s\n" "$target" "$backup"
    fi

    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
    printf "linked: %s -> %s\n" "$target" "$source"
}

link_path "$REPO_DIR/xorg/Xmodmap" "$HOME_DIR/.Xmodmap"
link_path "$REPO_DIR/xorg/xprofile" "$HOME_DIR/.xprofile"
link_path "$REPO_DIR/latexmk/latexmkrc" "$HOME_DIR/.latexmkrc"
link_path "$REPO_DIR/i3" "$HOME_DIR/.config/i3"
link_path "$REPO_DIR/alacritty" "$HOME_DIR/.config/alacritty"
link_path "$REPO_DIR/compton/compton" "$HOME_DIR/.config/compton/compton"
link_path "$REPO_DIR/rime" "$HOME_DIR/.config/ibus/rime"
link_path "$REPO_DIR/ranger" "$HOME_DIR/.config/ranger"
link_path "$REPO_DIR/zathura/zathurarc" "$HOME_DIR/.config/zathura/zathurarc"

if [ -d "$BACKUP_ROOT" ]; then
    printf "\nDone. Backups are stored under: %s\n" "$BACKUP_ROOT"
else
    printf "\nDone. No backup was needed.\n"
fi
