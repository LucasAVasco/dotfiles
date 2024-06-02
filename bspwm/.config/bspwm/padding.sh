#!/bin/sh
#
# Apply padding to the Bspwm session


# Multiple nodes
bspc config top_padding 31  # Remember to reserve some space to status bar
bspc config right_padding 5
bspc config bottom_padding 5
bspc config left_padding 5
bspc config window_gap 10

# Single monocle
bspc config top_monocle_padding 10
bspc config right_monocle_padding 10
bspc config bottom_monocle_padding 10
bspc config left_monocle_padding 10
