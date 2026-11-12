#!/bin/bash

source ~/.local/lib/dotfiles/bash/strict.sh

source ~/.local/lib/dotfiles/bash/linux/session.sh


case "$(linux_session_get_type)" in
	x11)
		pkill-wait -u "$UID" picom 2> /dev/null || true
		picom --dbus &
		;;

	wayland)
		# Compositor is integrated into the Wayland session, so no need to start it manually
		;;

	*)
		echo 'Unsupported session type, compositor will not be started!' >&2
		exit 1
		;;
esac
