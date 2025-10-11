#!/bin/bash
#
# Interface to manage the Bspwm session with Rofi. Interactively manage the session with Rofi


# Paths
current_dir=$(realpath -m -- "$0/../")


# Content to be displayed in Rofi
buttons=(
	'Shutdown;kshutdown' 'Reboot;system-restart' 'Suspend;system-suspend' 'Hibernate;system-hibernate'
	'Lock screen;lock-screen' 'Logout;system-switch-user'
	)

content=''
for loop in "${buttons[@]}"; do
	content+=$(echo -n "$loop" | sed 's/;/\\0icon\\x1f/')
	content+='\n'
done

# Displays Rofi interface
selected_command=$(echo -en "$content" | rofi -dmenu -theme "$current_dir/themes/session_manager.rasi" -p 'Session manager: ')

# Executes the command
case $selected_command in
	# Shutdown
	Shutdown )
		shutdown now
	;;

	# Reboot
	Reboot )
		reboot
	;;

	# Suspend
	Suspend )
		systemctl suspend
	;;

	# Hibernate
	Hibernate )
		systemctl hibernate
	;;

	# Lock-screen
	'Lock screen' )
		~/.config/screenlocker/run.sh
	;;

	# Switch-user
	'Logout' )
		if [[ -n "$CUSTOM_DESKTOP_LOGOUT_COMMAND" ]]; then
			bash -c "$CUSTOM_DESKTOP_LOGOUT_COMMAND"
		fi
	;;
esac
