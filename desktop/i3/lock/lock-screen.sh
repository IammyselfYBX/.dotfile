#!/usr/bin/env bash
# i3 wallpaper lock screen. Managed with ~/.config/i3.
set -u

I3_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/i3"
DOTFILE_DIR="${DOTFILE_DIR:-$HOME/.dotfile}"
WALLPAPER="$DOTFILE_DIR/assets/wallpapers/lockscreen-wallpaper.png"
BLANK_AFTER="${I3_LOCK_BLANK_SECONDS:-60}"

if [ ! -r "$WALLPAPER" ]; then
    echo "lock-screen: lock wallpaper not found: $WALLPAPER" >&2
    exit 1
fi

restore_display_power() {
    # Unlocked state: never blank or power off automatically.
    xset s off 2>/dev/null || true
    xset -dpms 2>/dev/null || true
}

trap restore_display_power EXIT INT TERM HUP

# Locked state only: blank the screen after 60 seconds.
# X screen-saver blanking covers VNC; DPMS powers off physical monitors.
xset s "$BLANK_AFTER" "$BLANK_AFTER" 2>/dev/null || true
xset +dpms 2>/dev/null || true
xset dpms 0 0 "$BLANK_AFTER" 2>/dev/null || true

i3lock \
    --nofork \
    --fill \
    --ignore-empty-password \
    --clock \
    --show-failed-attempts \
    --image "$WALLPAPER" \
    --time-str='%H:%M' \
    --date-str='%A, %Y-%m-%d' \
    --time-color=ffffffff \
    --date-color=ffffffff \
    --timeoutline-color=000000cc \
    --dateoutline-color=000000cc \
    --timeoutline-width=2 \
    --dateoutline-width=2 \
    --time-size=72 \
    --date-size=20 \
    --time-pos='x+w/2:y+90' \
    --date-pos='x+w/2:y+150' \
    --ind-pos='x+w/2:y+h-150'
status=$?

restore_display_power
trap - EXIT INT TERM HUP
exit "$status"
