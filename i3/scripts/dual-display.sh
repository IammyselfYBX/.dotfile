#!/usr/bin/env bash
# Keep the built-in display and the native HDMI output arranged as one desktop.
set -u

WALLPAPER="$HOME/.config/i3/backgrounds/little.png"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
LOCK_FILE="$RUNTIME_DIR/i3-dual-display-${UID}.lock"

exec 9>"$LOCK_FILE"
if ! flock -n 9; then
    exit 0
fi

xrandr_state() {
    xrandr --query 2>/dev/null \
        | awk '/ connected/ || / disconnected/ { print $1, $2, $3 }' \
        | cksum
}

apply_layout() {
    local hdmi_state

    hdmi_state=$(xrandr --query 2>/dev/null \
        | awk '$1 == "HDMI-1" { print $2; exit }')

    if [ "$hdmi_state" = "connected" ]; then
        xrandr --output HDMI-1 --auto --right-of eDP-1 >/dev/null 2>&1 || true
    else
        # Keep a disconnected output from retaining a stale CRTC and workspace.
        xrandr --output HDMI-1 --off >/dev/null 2>&1 || true
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
