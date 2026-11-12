#!/bin/bash
#
# Startup script that can be executed more than once in a Bspwm session. Reset the settings and applications if executed more than once.

# Fix cursor theme (need to be run before starting kdeconnect)
set_theme --fix-cursor

# Default custom-desktop initialization
~/.config/custom-desktop/init.sh

# Starts sxhkd or sends a signal to apply the changes of the Sxhkd configurations
if [[ "$(pgrep -f sxhkd)" == "" ]]; then
	sxhkd -c ~/.config/bspwm/sxhkdrc &
else
	pkill -u "$UID" -USR1 -x sxhkd
fi

# Programs that can be initialized more than once (does not cause and error)

nitrogen --restore &
kdeconnect-indicator &
nm-applet &
ibus-daemon --daemonize --xim
pulseaudio --start &

# Bspwm window management configurations

bspc config split_ratio          0.50
bspc config borderless_monocle   true
bspc config gapless_monocle      true

bspc config normal_border_color  '#777777'
bspc config focused_border_color '#ff6633'

bspc config border_width         3

bspc config single_monocle true

source ~/.config/bspwm/padding.sh

# hardware and devices configurations
~/.config/bspwm/rules.sh
