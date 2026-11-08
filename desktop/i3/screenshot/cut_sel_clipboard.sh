#!/bin/sh
# Select a screen region and copy it to the clipboard without keeping a file.
set -eu

tmp_file=$(mktemp "${XDG_RUNTIME_DIR:-/tmp}/i3-screenshot-clipboard-XXXXXX.png")
trap 'rm -f "$tmp_file"' EXIT HUP INT TERM

# maim + slop provide an interactive rectangular selection.
maim -s "$tmp_file"

# xclip reads the image and then owns the clipboard selection.
xclip -selection clipboard -t image/png -i "$tmp_file"

notify-send -a i3 -i edit-copy "截图已复制" "所选区域已复制到剪贴板" >/dev/null 2>&1 || true
