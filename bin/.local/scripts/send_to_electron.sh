#!/usr/bin/env bash

hyprctl activewindow | grep "$2: $3"
if [[ $? -eq 0 ]]; then
    hyprctl dispatch sendshortcut $1, $2:$3
else
    hyprctl --batch "dispatch focuswindow $2:$3; dispatch sendshortcut $1, $2:$3; dispatch focuscurrentorlast"
fi
