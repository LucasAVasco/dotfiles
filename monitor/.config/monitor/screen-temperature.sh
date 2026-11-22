#!/bin/bash
#
# Manages the screen temperature filter.

source ~/.local/lib/dotfiles/bash/strict.sh

source ~/.local/lib/dotfiles/bash/help.sh

help_handle y "$@" <<EOF
	Manages the screen temperature filter.

	Commands:

	screen-temperature get-warm     Return the configured screen temperature value.

	screen-temperature set-warm     Configure the screen temperature value. Must be a number between 1000 and 2500, or the 'default' string.

	screen-temperature enable       Enable the screen temperature filter on high workspaces (from workspace 6 to 10).

	screen-temperature disable      Disable the screen temperature filter.

	screen-temperature is-enabled      Outputs 'y' is it is enabled, 'n' otherwise
EOF

# All operations relative to the current directory
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

# Main command
if (( "$#" < 1 )); then
	echo "You should provide a main command" >&2
	exit 1
fi

main_command="$1"
shift

# Defaults
DEFAULT_WARM=3000
DCONF_GROUP=/apps/custom-desktop/screen-temperature

# Handle main command
case "$main_command" in
	set-warm)
		warm="$1"

		if [[ "$warm" == "default" ]]; then
			warm="$DEFAULT_WARM"
		fi

		if [[ "$warm" =~ ^[0-9]+$ ]]; then
			:
		else
			echo "Temperature is not a positive number" >&2
			exit 1
		fi

		if [[ "$warm" -lt 1000 || "$warm" -gt 25000 ]]; then
			echo "Temperature must be in the range 1000-25000" >&2
			exit 1
		fi

		dconf write "$DCONF_GROUP/warm-temperature" "$warm"
		;;

	get-warm)
		warm="$(dconf read "$DCONF_GROUP/warm-temperature")"
		if [[ -z "$warm" ]]; then
			warm="$DEFAULT_WARM"
		fi

		printf "%d" "$warm"
		;;

	enable)
		dconf write "$DCONF_GROUP/enabled" true
		;;

	disable)
		dconf write "$DCONF_GROUP/enabled" false
		./update-workspace-screen-temp.sh 1
		;;

	is-enabled)
		if [[ "$(dconf read "$DCONF_GROUP/enabled")" == "false" ]]; then
			echo -n n
		else
			echo -n y
		fi
		;;

	*)
		echo "Unknown main command: $main_command" >&2
		exit 1
		;;
esac
