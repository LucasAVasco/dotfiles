#!/bin/bash
#
# Updates/generate my custom theme extended with dircolors

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

dest=~/.config/vifm/colors/mytheme.vifm

# Creates the dircolors file from the prepended highlights
cp ./prepend.vifm "$dest"

# Appends the dircolors highlights
vifm-convert-dircolors -e >> "$dest"

# Appends the appended highlights
cat ./append.vifm >> "$dest"
