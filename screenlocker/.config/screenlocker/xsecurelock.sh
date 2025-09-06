#!/bin/bash
#
# Locks the screen with XSecureLock. Also disables Bucklespring if it is running


# If your images or videos have black bands, add the 'panscan=1.0' line
# to your '~/.config/mpv/mpv.conf' file.


# Does nothing if the screen locker is already running
pgrep 'xsecurelock' && return


# Saves the current state of the bucklespring and stops it. It is strongly recommended to stop the bucklespring before locking the screen
# because it is possible to recognize the pressed key by the bucklespring sounds
is_buckle_on=$(~/.config/keyboard/sound_emulator.sh status)
~/.config/keyboard/sound_emulator.sh stop


# Paths
wallpapers_path="/home/shared_folder/screen_locker/wallpapers/"


# XSecureLock configurations and run
export XSECURELOCK_COMPOSITE_OBSCURER=0
export XSECURELOCK_SAVER=saver_mpv
export XSECURELOCK_IMAGE_DURATION_SECONDS=4
export XSECURELOCK_LIST_VIDEOS_COMMAND="find $wallpapers_path -type f"


# Screen locker
xsecurelock


# Restores the previous state of the bucklespring
if [ "$is_buckle_on" = "on" ]; then
	~/.config/keyboard/sound_emulator.sh start
fi
