#!/usr/bin/env bash
# Keep the built-in display and the native HDMI output arranged as one desktop.
set -u

WALLPAPER="$HOME/.config/i3/backgrounds/little.png"
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/i3/dual-display.conf"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
LOCK_FILE="$RUNTIME_DIR/i3-dual-display-${UID}.lock"

# Defaults; override them in dual-display.conf.
INTERNAL_OUTPUT="eDP-1"
EXTERNAL_OUTPUT="HDMI-1"
EXTERNAL_POSITION="right"

if [ -r "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    . "$CONFIG_FILE"
fi

case "$EXTERNAL_POSITION" in
    right) POSITION_ARG="--right-of" ;;
    left) POSITION_ARG="--left-of" ;;
    above) POSITION_ARG="--above" ;;
    below) POSITION_ARG="--below" ;;
    *)
        printf "Invalid EXTERNAL_POSITION: %s (expected right, left, above, or below)\n" "$EXTERNAL_POSITION" >&2
        exit 2
        ;;
esac

exec 9>"$LOCK_FILE"
if ! flock -w 5 9; then
    exit 0
fi

xrandr_state() {
    xrandr --query 2>/dev/null \
        | awk '/ connected/ || / disconnected/ { print $1, $2, $3, $4 }' \
        | cksum
}

apply_layout() {
    local external_state

    external_state=$(xrandr --query 2>/dev/null \
        | awk -v output="$EXTERNAL_OUTPUT" '$1 == output { print $2; exit }')

    if [ "$external_state" = "connected" ]; then
        xrandr --output "$EXTERNAL_OUTPUT" --auto "$POSITION_ARG" "$INTERNAL_OUTPUT" >/dev/null 2>&1 || true
    else
        # Keep a disconnected output from retaining a stale CRTC and workspace.
        xrandr --output "$EXTERNAL_OUTPUT" --off >/dev/null 2>&1 || true
    fi

    # feh applies the image independently to every Xinerama monitor.
    feh --bg-fill "$WALLPAPER" >/dev/null 2>&1 || true
}

apply_layout
last_state=$(xrandr_state)

while sleep 2; do
    if ! xrandr --query >/dev/null 2>&1; then
        exit 0
    fi

    current_state=$(xrandr_state)
    if [ "$current_state" != "$last_state" ]; then
        apply_layout
        last_state=$(xrandr_state)
    fi
done
