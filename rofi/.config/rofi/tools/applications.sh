#!/bin/bash
#
# Launch an application with rofi


current_dir=$(realpath -m -- "$0/../")


rofi -theme "$current_dir/themes/applications.rasi" -modi "run,ssh,drun" -show drun
