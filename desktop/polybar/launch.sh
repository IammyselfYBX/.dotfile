#!/bin/sh
killall -q polybar

echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
polybar bar1 >>/tmp/polybar1.log 2>&1 & disown
polybar bar2 >>/tmp/polybar2.log 2>&1 & disown

echo "Bars launched..."

#while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar example
