#!/bin/bash
#
# Update the wallpaper if its file changed.

pkill-wait -u "$USER" hyprpaper || true
nohup hyprpaper > /dev/null &
