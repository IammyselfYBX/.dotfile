#!/bin/bash
# Apply the touchpad settings recorded in the i3 session.
# Run twice so devices that appear just after login are also configured.
set -u

apply_touchpad_settings() {
    xinput list --short 2>/dev/null |
        sed -n 's/.*[Tt]ouchpad.*id=\([0-9][0-9]*\).*/\1/p' |
        while IFS= read -r id; do
            [ -n "$id" ] || continue
            xinput set-prop "$id" "libinput Tapping Enabled" 1 2>/dev/null || true
            xinput set-prop "$id" "libinput Natural Scrolling Enabled" 1 2>/dev/null || true
        done
}

apply_touchpad_settings
sleep 1
apply_touchpad_settings
