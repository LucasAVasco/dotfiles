#!/bin/bash
#
# Run a command in a new shell. If starting an interactive shell, remove all environment variables related to Vifm before starting it

set -e

# Start a new interactive shell without Vifm environment variables when running Vifm in interactive mode
if [[ "$1" == "-c" && "$2" == "$SHELL" && $# -eq 2 ]]; then
	clear
	exec ~/.config/vifm/scripts/internal/run-without-env "$SHELL" "$@"
fi

exec "$SHELL" "$@"
