#!/bin/sh
set -eu

tmp_file=$(mktemp "${XDG_RUNTIME_DIR:-/tmp}/i3-screenshot-XXXXXX.png")
trap 'rm -f "$tmp_file"' EXIT HUP INT TERM

scrot -u -b -m -o "$tmp_file"
xclip -selection clipboard -t image/png -i "$tmp_file" </dev/null >/dev/null 2>&1 &

mkdir -p "$HOME/Pictures"
output="$HOME/Pictures/$(date +%Y-%m-%d_%H-%M-%S)_current.png"
mv "$tmp_file" "$output"
trap - EXIT HUP INT TERM
printf '%s\n' "$output"
