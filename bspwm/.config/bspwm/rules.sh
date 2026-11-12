#!/bin/bash
#
# Override the default Bspwm rules

# Remove the default rules
bspc rule -r '*'

# Make all floating windows open in the center of the screen
bspc rule -a '*' center=on

# Makes some applications float
to_float=(
	'Gufw.py' 'Nm-connection-editor' 'File-roller' 'Gpick' 'processing-app-Base' 'arduinopc' 'Pdfarranger'
	'Tor Browser' 'torbrowser-launcher' 'Java' 'Gdebi-gtk' 'Gnome-calculator' 'scrcpy' 'Clamtk' 'Catfish'
	'Gtkhash' 'Software-properties-gtk' 'Org.gnome.Nautilus' 'Zotero:Toplevel' 'firetools' 'Protonvpn' 'rclone-browser'
	'metadata-cleaner' 'Veracrypt', 'Gnome-screenshot' 'Xfce4-mime-settings'
)

for app in ${to_float[@]}; do
	bspc rule -a "$app" state=floating;
done

# Configuration to specific applications
bspc rule -a mplayer2 state=floating
bspc rule -a Kupfer.py focus=on
bspc rule -a Screenkey manage=off
bspc rule -a Pavucontrol state=floating rectangle=850x400

# Conky above the screen
bspc rule -a Conky-top layer=ABOVE
