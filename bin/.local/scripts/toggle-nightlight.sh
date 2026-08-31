#!/bin/bash

# Toggle nightlight by switching sunsetr presets.
#   default -> geo schedule, warms the screen after sunset
#   day     -> static 6500K, nightlight off
#
# Replaces omarchy-toggle-nightlight, which drives hyprsunset and would
# contend with sunsetr over gamma control.

set -u

# The key should still work if the process that owns sunsetr has gone away.
# Not `sunsetr --background`: that self-launches via `hyprctl dispatch exec`,
# which Hyprland 0.56 rejects under its Lua dispatch syntax. setsid detaches
# it from this keybind's short-lived shell instead.
if ! pgrep -x sunsetr >/dev/null; then
  setsid sunsetr >/dev/null 2>&1 </dev/null &
  sleep 1
fi

if [[ $(sunsetr preset active 2>/dev/null | tr -d '[:space:]') == "day" ]]; then
  sunsetr preset default >/dev/null 2>&1
  notify-send -a Nightlight -t 2000 "Nightlight on" "Following the sunset schedule"
else
  sunsetr preset day >/dev/null 2>&1
  notify-send -a Nightlight -t 2000 "Nightlight off" "Holding 6500K"
fi
