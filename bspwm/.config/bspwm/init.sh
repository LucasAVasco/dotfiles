#!/bin/bash
#
# Startup script that can be executed more than once in a Bspwm session. Reset the settings and applications if executed more than once.


# Fix cursor theme (need to be run before starting kdeconnect)
set_theme --fix-cursor


# #region Programs that need to be reinitialized every time this script is run

# Screen locker
pkill -u "$UID" xss-lock 2> /dev/null
xss-lock -- ~/.config/screenlocker/idle.sh &

# Compositor
pkill -u "$UID" picom 2> /dev/null
sleep 0.1  # Need to add a delay because the compositor can not be started immediately after kill the previous one (sometimes will not be reloaded)
picom --experimental-backends --dbus &

# Buclespring (keyboard sound emulation)
~/.config/bspwm/buckle.sh stop
~/.config/bspwm/buckle.sh start

# File manager as a daemon
pkill -u "$UID" thunar 2> /dev/null
thunar --daemon &

# Polybar
pkill -u "$UID" polybar 2> /dev/null
~/.config/polybar/bars/bspwm-topbar/start.sh &

# Starts sxhkd or sends a signal to apply the changes of the Sxhkd configurations
if [[ "$(pgrep -f sxhkd)" == "" ]]; then
	sxhkd -c ~/.config/bspwm/sxhkdrc &
else
	pkill -u "$UID" -USR1 -x sxhkd
fi

# #endregion


# # #region Programs that can be initialized more than once (does not cause and error)

nitrogen --restore &
kdeconnect-indicator &
nm-applet &
/usr/lib/*/xfce4/notifyd/xfce4-notifyd &
ibus-daemon --daemonize --xim
pulseaudio --start &
gnome-keyring-daemon --start &

# #endregion


# # #region Bspwm window management configurations

bspc config split_ratio          0.50
bspc config borderless_monocle   true
bspc config gapless_monocle      true

bspc config normal_border_color  '#666666'
bspc config focused_border_color '#aaaaaa'

bspc config border_width         1

bspc config single_monocle true

source ~/.config/bspwm/padding.sh

# #endregion


# #region hardware and devices configurations

~/.config/touchpad/setup.sh

# #endregion


# Rules
~/.config/bspwm/rules.sh
