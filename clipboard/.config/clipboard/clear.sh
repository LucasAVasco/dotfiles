#!/bin/bash
#
# Clear the user clipboard.

current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)

no_notify=n
async=n

while [[ "$#" -gt 0 ]]; do
	case "$1" in
		--no-notify )
			no_notify=y
			;;

		--async )
			async=y
			;;

		*)
			break
			;;
	esac

	shift
done

# Arguments of the main command
args=''
if [[ "$no_notify" == y ]]; then
	args="$args --no-notify"
fi
args="$args $@"

# Runs the main command
if [[ "$async" == y ]]; then
	nohup "$current_dir/__clear.sh" $args > /dev/null 2>&1 &
else
	"$current_dir/__clear.sh" $args
fi
