#!/bin/bash
#
# Simple helper script to start and stop the Bucklespring
#
# Se the options with 'buckle.sh help'


buckle_command='buckle -f'


help_message() {
	echo "
	Usage: buckle.sh [OPTION]

	Options:
	  help                Show this help help message
	  status              Check if the Bucklespring is running. Returns 'on' or 'off'.
	  start               Start the Bucklespring.
	  stop                Stop the Bucklespring.
	  toogle              Toggles the Bucklespring playback. If the Bucklespring is not running, start it. If the Bucklespring is running, stop it.
	" | sed 's/^\t//g'
}


# Starts bucklespring in parallel
start_buckle() {
	nohup $buckle_command > /dev/null &
}


# Stops bucklespring. Returns an error if the Bucklespring is not running
stop_buckle() {
	pkill -f "^${buckle_command}$"
}


case "$1" in
	status)
		pgrep -f "^${buckle_command}$" > /dev/null && echo 'on' || echo 'off'
		;;

	start)
		start_buckle
		;;

	stop)
		stop_buckle
		;;

	toogle)
		# Toggle the Bucklespring playback. If the Bucklespring is not running, start it. If the Bucklespring is running, stop it.
		#
		# It is required to have PulseAudio server running before starting Bucklespring. Otherwise, this script will wait for
		# the server to be ready.
		stop_buckle || {
			# Wait until the PulseAudio server is ready. Otherwise the PulseAudio can't recognize the Bucklespring playback
			# This command will start the PulseAudio server if it isn't running and end after it starts
			pactl stat > /dev/null

			# Start the Bucklespring
			start_buckle
		}
		;;

	help)
		help_message
		;;

	*)
		echo "Script: 'buckle.sh'; unrecognized option: '$1'"
		help_message
		;;
esac
