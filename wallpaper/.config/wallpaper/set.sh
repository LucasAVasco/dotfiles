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
		set.sh [-i|--interactive] [-l|--screen-locker] [--] <wallpaper.jpg>
			Sets the wallpaper. The '-i' or '--interactive' flag allows you to select the wallpaper interactively (you do not need to
			provide the path to the wallpaper as an argument). The '-l' or '--screen-locker' flag sets the wallpaper for the screen locker
			instead of the normal wallpaper.

		NOTES
		You can set a command to be executed after the wallpaper is set with the \$CUSTOM_DESKTOP_SET_WALLPAPAER_COMMAND variable.
EOF
}

help_call_help_function help y "$@"

# }}}

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
wallpaper_dir="$HOME/.local/share/custom_desktop/wallpaper"

# Parses the arguments
interactive=n
screen_locker=n

while [[ "$#" -gt 0 ]]; do
	case "$1" in
		-i|--interactive)
			interactive=y
			;;

		-l|--screen-locker)
			screen_locker=y
			;;

		--)
			shift
			break
			;;

		*)
			break
			;;
	esac

	shift
done

# Path to the wallpaper to change
if [[ $screen_locker == y ]]; then
	wallpaper_path="$wallpaper_dir/lock.jpg"
else
	wallpaper_path="$wallpaper_dir/normal.jpg"
fi

# Gets the current wallpaper
if [[ -f "$wallpaper_path" ]]; then
	current_normal_wallpaper_path=$(readlink -f "$wallpaper_dir/normal.jpg")
else
	current_normal_wallpaper_path=''
fi

# Restores the normal wallpaper if the user does not set the `$must_restore_normal_wallpaper` variable to 'n' {{{

must_restore_normal_wallpaper=y
trap restore_normal_wallpaper EXIT

# Restore the original wallpaper.
restore_normal_wallpaper() {
	if [[ "$must_restore_normal_wallpaper" == 'y' ]]; then
		"$current_dir/set.sh" -- "$current_normal_wallpaper_path"
	fi
}

# }}}

# Next wallpaper to set
next_wallpaper_path=''

if [[ $interactive == y ]]; then
	# The user want to interactively select the wallpaper from the wallpaper folder
	next_wallpaper_path=$(cd /home/shared_folder/wallpapers/ && \
		find -type f -name "*.jpg" | \
		fzf --header="Select wallpaper" \
		--preview "$current_dir/set.sh -- '/home/shared_folder/wallpapers/{}' >/dev/null 2>&1 && pretty-preview '/home/shared_folder/wallpapers/{}'")

	if [[ "$next_wallpaper_path" == '' ]]; then # User aborted
		echo 'Aborted.' >&2
		exit 1
	fi

	next_wallpaper_path="/home/shared_folder/wallpapers/$next_wallpaper_path"
else
	# The user provided a path to the wallpaper as an argument
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

# Disables restoring the normal wallpaper
must_restore_normal_wallpaper=n
if [[ $screen_locker == y ]]; then
	# In interactive mode, we replace the normal wallpaper as a visual feedback of the change. We always need to restore the normal
	# wallpaper to its original state after it
	must_restore_normal_wallpaper=y
fi

# Changing to the next wallpaper
mkdir -p "$wallpaper_dir"
ln -sf "$next_wallpaper_path" "$wallpaper_path"

# Custom command that depends on the desktop
if [[ -n "$CUSTOM_DESKTOP_SET_WALLPAPAER_COMMAND" ]]; then
	eval "$CUSTOM_DESKTOP_SET_WALLPAPAER_COMMAND"
fi
