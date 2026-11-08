#!/usr/bin/env bash
# Link managed dotfiles and shared assets into $HOME.
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

link_children() {
    local source_root="$1"
    local target_root="$2"
    local source

    [ -d "$source_root" ] || return 0
    mkdir -p "$target_root"
    for source in "$source_root"/*; do
        [ -d "$source" ] || continue
        link_path "$source" "$target_root/$(basename "$source")"
    done
}

links=(
    "$REPO_DIR/desktop/xorg/Xmodmap|$HOME_DIR/.Xmodmap"
    "$REPO_DIR/desktop/xorg/xprofile|$HOME_DIR/.xprofile"
    "$REPO_DIR/desktop/xorg/Xresources|$HOME_DIR/.Xresources"
    "$REPO_DIR/desktop/xorg/xinitrc|$HOME_DIR/.xinitrc"
    "$REPO_DIR/desktop/xorg/xsession|$HOME_DIR/.xsession"
    "$REPO_DIR/desktop/xorg/fehbg|$HOME_DIR/.fehbg"
    "$REPO_DIR/desktop/xorg/modmap|$HOME_DIR/.modmap"
    "$REPO_DIR/desktop/xorg/Xclients|$HOME_DIR/.Xclients"
    "$REPO_DIR/documents/latexmk/latexmkrc|$HOME_DIR/.latexmkrc"
    "$REPO_DIR/shell/dir_colors|$HOME_DIR/.dir_colors"
    "$REPO_DIR/shell/bash_logout|$HOME_DIR/.bash_logout"
    "$REPO_DIR/terminal/alacritty|$HOME_DIR/.config/alacritty"
    "$REPO_DIR/terminal/wezterm|$HOME_DIR/.config/wezterm"
    "$REPO_DIR/terminal/tmux/tmux.conf|$HOME_DIR/.config/tmux.conf"
    "$REPO_DIR/desktop/i3|$HOME_DIR/.config/i3"
    "$REPO_DIR/desktop/compton|$HOME_DIR/.config/compton"
    "$REPO_DIR/desktop/polybar|$HOME_DIR/.config/polybar"
    "$REPO_DIR/desktop/autostart|$HOME_DIR/.config/autostart"
    "$REPO_DIR/input-method/rime|$HOME_DIR/.config/ibus/rime"
    "$REPO_DIR/file-manager/ranger|$HOME_DIR/.config/ranger"
    "$REPO_DIR/documents/zathura/zathurarc|$HOME_DIR/.config/zathura/zathurarc"
    "$REPO_DIR/editors/vscode/settings.json|$HOME_DIR/.config/Code/User/settings.json"
    "$REPO_DIR/editors/vscode/snippets|$HOME_DIR/.config/Code/User/snippets"
)

for mapping in "${links[@]}"; do
    link_path "${mapping%%|*}" "${mapping#*|}"
done

link_children "$REPO_DIR/assets/fonts" "$HOME_DIR/.local/share/fonts"

if [ "$DRY_RUN" -eq 0 ] && command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f >/dev/null 2>&1 || true
fi

if [ "$DRY_RUN" -eq 1 ]; then
    printf "\nDry run complete. No changes were made.\n"
elif [ -d "$BACKUP_ROOT" ]; then
    printf "\nDone. Backups are stored under: %s\n" "$BACKUP_ROOT"
else
    printf "\nDone. No backup was needed.\n"
fi
