#!/bin/bash
#
# Set the keyboard layout to same defined by the XKB_DEFAULT_LAYOUT environment variable.

source ~/.local/lib/dotfiles/bash/strict.sh

source ~/.local/lib/dotfiles/bash/linux/session.sh

case "$(linux_session_get_type)" in
	x11)
		if [[ -n "$XKB_DEFAULT_LAYOUT" ]]; then
			setxkbmap -layout "$XKB_DEFAULT_LAYOUT"
		fi
		;;

	wayland)
		# Keyboard layout is set in the Wayland session, so no need to set it manually
		;;

	*)
		echo 'Unsupported session type, Keyboard layout will not be set!' >&2
		exit 1
		;;
esac
