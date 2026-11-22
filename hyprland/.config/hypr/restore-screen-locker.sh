#!/bin/bash
#
# Restore the screen locker if it crashed during a session lock.
#
# You need to provide the Hyprland instance id as the first argument. The session locker will be restored and you can unlock the screen.
#
# $1: Hyprland instance id

instance="${1:-0}"

hyprctl --instance "$instance" eval 'hl.clear_crashed_lockscreen()'
