#!/bin/bash
#
# Toggle Bspwm padding between 'no_padding.sh' and 'padding.sh'


# If 'top_monocle_padding' is '0', meas that we are in 'no_padding.sh'
if [ "$(bspc config top_monocle_padding)" == "0" ]; then
	~/.config/bspwm/padding.sh

else
	~/.config/bspwm/no_padding.sh
fi
