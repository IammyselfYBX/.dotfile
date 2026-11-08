#!/usr/bin/env bash
# Link shared font families into ~/.local/share/fonts and refresh the font cache.
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
FONT_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.dotfile-backups/fonts-$(date +%Y%m%d-%H%M%S)}"

mkdir -p "$FONT_ROOT"
for source in "$REPO_DIR"/assets/fonts/*; do
    [ -d "$source" ] || continue
    target="$FONT_ROOT/$(basename "$source")"
    if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$source")" ]; then
        continue
    fi
    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP_ROOT"
        mv "$target" "$BACKUP_ROOT/$(basename "$target")"
        printf "backed up: %s\n" "$target"
    fi
    ln -s "$source" "$target"
    printf "linked: %s -> %s\n" "$target" "$source"
done

if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f >/dev/null 2>&1 || true
fi
