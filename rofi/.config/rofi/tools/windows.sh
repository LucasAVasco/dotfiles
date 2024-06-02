#!/bin/bash
#
# Select a window with Rofi and go to it


current_dir=$(realpath -m -- "$0/../")


rofi -theme "$current_dir/themes/windows.rasi" -modi window -show window
