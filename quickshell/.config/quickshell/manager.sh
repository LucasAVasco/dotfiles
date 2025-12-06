#!/bin/bash
#
# Manage my QuickShell configurations.

set -e

source ~/.config/bash/libs/help.sh

# Help message {{{

help() {
	help_msg_format '\t\t' <<EOF
		Manage my QuickShell configurations.

		USAGE
		$0 <command>

		COMMANDS
		$0 is-active
			Checks if the QuickShell process is running.

		$0 start
			Starts QuickShell process.

		$0 stop
			Stops the QuickShell process.

		$0 restart
			Restarts the QuickShell process.

		$0 run <script>
			Runs a QuickShell process script at ~/.config/quickshell/scripts/.

EOF
}

help_call_help_function help y "$@"

# }}}

# Change to the directory of this script
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

# Ensures the '.qmlls.ini' file exists (required by 'qmlls' to work with QuickShell)
touch ./.qmlls.ini || true # If '.qmlls.ini' is broken, `touch` will fail. The `true` command will ignore the error

# Main command to run
main_command="$1"
shift

# Check if the QuickShell process is running.
#
# Returns 'y' if running, 'n' if not.
quickshell_is_running() {
	pgrep -u "$USER" "^quickshell$" >/dev/null && echo -n y || echo -n n
}

# Start the QuickShell process in the background.
start_quickshell() {
	if [[ $(quickshell_is_running) == y ]]; then
		return
	fi

	nohup quickshell > /dev/null 2>&1 &
}

# Wait for the QuickShell process to start
wait_quickshell_start() {
	while [[ true ]]; do
		quickshell ipc show >/dev/null 2>&1 && break
		sleep 0.5
	done
}

# Stop the QuickShell process.
#
# This will wait for the QuickShell process to stop.
stop_quickshell() {
	pkill-wait -u "$USER" "^quickshell$"
}

case "$main_command" in
	is-active)
		quickshell_is_running
		;;

	start)
		start_quickshell
		;;

	stop)
		stop_quickshell
		;;

	restart)
		stop_quickshell
		start_quickshell
		;;

	run)
		start_quickshell
		wait_quickshell_start
		"./scripts/$1.sh"
		;;

	*)
		echo "Unknown command \"$main_command\"" >&2
		help
		exit 1
		;;
esac
