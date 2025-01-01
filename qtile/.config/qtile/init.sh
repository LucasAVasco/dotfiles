#!/bin/bash


# Xorg configuration
if [[ -z "$WAYLAND_DISPLAY" ]]; then
	if [[ -z "$QTILE_XEPHYR" ]]; then
		pkill-wait -u $UID picom 2> /dev/null
		pkill-wait -u $UID polybar 2> /dev/null
	fi

	sleep 1  # Need to add a delay because some applications can not be started immediately after send the kill signal to the previous one

	~/.config/polybar/bars/qtile_topbar/start.sh &
	picom --dbus &

# Wayland configuration
else
	echo 'TODO'
fi


# Notification daemon. Dunst supports Xorg and Wayland
~/.config/dunst/enable.sh


# Screen locker
~/.config/screenlocker/manager.sh enable --no-notify &


# Keyboard sound emulator
~/.config/keyboard/sound_emulator.sh start


# Hide cursor
~/.config/mouse/autohide-cursor.sh


# Shows a message if there are running Docker containers
~/.config/docker/notify-running-containers.sh &
