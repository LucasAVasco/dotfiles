#!/bin/bash
#
# Library to manage my scripts used override some binaries.

source ~/.config/bash/libs/string.sh
source ~/.config/bash/libs/bin_fallback.sh

_bin_overrides_path=$(realpath ~/.local/dotfiles_bin_override/)

# Run a command without the influence of the override scripts.
#
# $1: command to execute.
# $2..n: Arguments to the command.
bin_overrides_call_without_override() {
	local cmd="$1"

	# Must manually install a fallback installer package if it exists (avoids a infinity recursion)
	if [[ $(bin_fallback_manager has "$1" ) == 'y' ]]; then
		if [[ $(bin_fallback_manager is-installed "$1") == 'n' ]]; then
			bin_fallback_manager install "$1"
		fi
	fi

	# Ignores the override scripts and executes the command
	for bin in $(whereis -b "$cmd" | cut -d: -f 2); do
		if [[ $(string_has_substring "$bin" "$_bin_overrides_path") == 'n' ]]; then
			command "$bin" "${@:2}"
			break
		fi
	done
}
