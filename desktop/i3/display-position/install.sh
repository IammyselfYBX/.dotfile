#!/bin/sh
# Install the display-position command into the user's local bin directory.
set -eu

FEATURE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"

chmod +x "$FEATURE_DIR/i3-display-position" "$FEATURE_DIR/dual-display.sh"
mkdir -p "$BIN_DIR"
ln -sfn "$FEATURE_DIR/i3-display-position" "$BIN_DIR/i3-display-position"

printf "Installed: %s/i3-display-position -> %s\n" "$BIN_DIR" "$FEATURE_DIR/i3-display-position"
