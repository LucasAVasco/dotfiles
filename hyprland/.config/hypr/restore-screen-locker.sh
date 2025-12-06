#!/bin/bash
#
# Restore the screen locker if it crashed during a session lock.
#
# You need to provide the Hyprland instance id as the first argument. The session locker will be restored and you can unlock the screen.
#
# $1: Hyprland instance id

instance=$1

hyprctl --instance "$instance" 'keyword misc:allow_session_lock_restore 1'
hyprctl --instance "$instance" "dispatch exec $HOME/.config/screenlocker/manager.sh run"
sleep 2 # Hyprland needs a little time to start QuickShell before disabling the session locker restore
hyprctl --instance "$instance" 'keyword misc:allow_session_lock_restore 0'
