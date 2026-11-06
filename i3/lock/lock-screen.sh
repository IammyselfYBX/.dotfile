#!/usr/bin/env bash
# i3 wallpaper lock screen. Managed with ~/.config/i3.
set -u

I3_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/i3"
WALLPAPER="$I3_DIR/backgrounds/lockscreen-wallpaper.png"

if [ ! -r "$WALLPAPER" ]; then
    echo "lock-screen: lock wallpaper not found: $WALLPAPER" >&2
    exit 1
fi

exec i3lock \
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
