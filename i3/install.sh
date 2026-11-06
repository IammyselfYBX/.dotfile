#!/bin/sh
# Install helper executables used by the i3 configuration.
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BIN_DIR="$HOME/.local/bin"

chmod +x "$ROOT_DIR"/brightness/*.sh
chmod +x "$ROOT_DIR"/screenshot/*.sh
chmod +x "$ROOT_DIR"/scripts/*.sh
chmod +x "$ROOT_DIR"/lock/betterlockscreen

mkdir -p "$BIN_DIR"
install -m 755 "$ROOT_DIR/brightness/screen_off.sh" "$BIN_DIR/screen_off"
install -m 755 "$ROOT_DIR/lock/betterlockscreen" "$BIN_DIR/betterlockscreen"

printf "Installed: %s/screen_off\n" "$BIN_DIR"
printf "Installed: %s/betterlockscreen\n" "$BIN_DIR"
