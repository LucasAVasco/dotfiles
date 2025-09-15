#!/bin/bash
#
# Install root dependencies for the devcontainer be able to run my dotfiles.

set -e

# Release file
release_file=''
if [[ -f /etc/lsb-release ]]; then
	release_file="/etc/lsb-release"

elif [[ -f /etc/os-release ]]; then
	release_file="/etc/os-release"
fi

# Current distribution ID
current_dist=''
while IFS=$'=' read entry_name entry_value; do
	if [[ $entry_name == 'DISTRIB_ID' ]] || [[ $entry_name == 'ID' ]]; then
		current_dist="$entry_value"
	fi
done < "$release_file"

# removes "" and '' from the distribution ID
current_dist="${current_dist/\'/}"
current_dist="${current_dist/\"/}"

# Installs system dependencies (requires root)
case "$current_dist" in
	alpine)
		apk add --force-refresh --no-cache \
			man-pages mandoc \
			sudo zsh \
			fzf eza bat zoxide curl grep \
			git \
			cmake make g++ # Required to build the ZSH prompt

		addgroup sudo 2> /dev/null && {
			echo 'Created `sudo` group'
		} || {
			echo '`sudo` group already created'
		}
	;;

	*)
		echo "Unknown distribution: $current_dist"
		exit 1
	;;
esac
