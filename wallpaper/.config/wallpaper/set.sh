#!/bin/bash
#
# Set the current session wallpaper.

set -e

source ~/.config/bash/libs/linux/session.sh
source ~/.config/bash/libs/help.sh

# Help message {{{

help() {
	help_msg_format '\t\t' <<EOF
		Set the current session wallpaper.

		USAGE
		set.sh <wallpaper.jpg>

		NOTES
		You can set a command to be executed after the wallpaper is set with the \$CUSTOM_DESKTOP_SET_WALLPAPAER_COMMAND variable.
EOF
}

help_call_help_function help y "$@"

# }}}

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
wallpaper_dir="$HOME/.local/share/wallpaper"
wallpaper_path="$wallpaper_dir/wallpaper.jpg"
current_wallpaper_path=$(readlink -f "$wallpaper_path")

# Restore the original wallpaper if the user does not set the `$must_restore_wallpaper` variable to 'n' {{{

must_restore_wallpaper=y
trap restore_wallpaper EXIT

# Restore the original wallpaper.
restore_wallpaper() {
	if [[ "$must_restore_wallpaper" == 'y' ]]; then
		"$current_dir/set.sh" "$current_wallpaper_path"
	fi
}

# }}}

# Next wallpaper to set
next_wallpaper_path=''

if [[ "$1" == '-i' || "$1" == '--interactive' ]]; then
	# The user want to interactively select the wallpaper from the wallpaper folder
	shift

	next_wallpaper_path=$(cd /home/shared_folder/wallpapers/ && \
		find -type f -name "*.jpg" | \
		fzf --header="Select wallpaper" \
		--preview "$current_dir/set.sh '/home/shared_folder/wallpapers/{}' && pretty-preview '/home/shared_folder/wallpapers/{}'")

	if [[ "$next_wallpaper_path" == '' ]]; then # User aborted
		echo 'Aborted.' >&2
		exit 1
	fi

	next_wallpaper_path="/home/shared_folder/wallpapers/$next_wallpaper_path"
else
	# The user provided a path to the wallpaper as an argument
	if [[ "$1" == '--' ]]; then
		shift
	fi

	next_wallpaper_path="$1"

	if [[ -z "$next_wallpaper_path" ]]; then
		echo 'You must provide a path to the wallpaper.' >&2
		exit 1
	fi
fi

# Check if the wallpaper exists
if [[ ! -f "$next_wallpaper_path" ]]; then
	echo "The wallpaper '$next_wallpaper_path' does not exist."
	exit 1
fi

# Changing to the next wallpaper
must_restore_wallpaper=n
mkdir -p "$wallpaper_dir"
ln -sf "$next_wallpaper_path" "$wallpaper_path"

# Custom command that depends on the desktop
if [[ -n "$CUSTOM_DESKTOP_SET_WALLPAPAER_COMMAND" ]]; then
	eval "$CUSTOM_DESKTOP_SET_WALLPAPAER_COMMAND"
fi
