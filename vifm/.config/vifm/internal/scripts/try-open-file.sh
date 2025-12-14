#!/bin/bash
#
# Open a single non-editable file with the `default_open` command.
#
# If the file should be edited in Vifm, do not open it and print the 'edit-in-vifm' message.

# Can not open more than one file
if [[ "$#" -gt 1 ]]; then
	echo 'edit-in-vifm'
	exit
fi

# Try to open a file.
#
# $1: File path
open_path() {
	local full=($(default_open --get-cmd -- "$@"))
	local command="${full[0]}"

	if [[ "$command" == 'nvim_new_win' || "$command" == 'default_file_manager' ]]; then
		echo 'edit-in-vifm'
	else
		command "${full[@]}"
	fi
}

open_path "$1"
