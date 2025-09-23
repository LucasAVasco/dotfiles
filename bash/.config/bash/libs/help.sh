#!/bin/bash
#
# Utilities functions to manage help messages.

# Format help message.
#
# $1: indentation to remove from the help message. A `sed` regex
# stdin: help message
# stdout: help message formatted
help_msg_format() {
	sed "s/^$1//g"
}

# Call a help function.
#
# $1: help function name.
# $2: should the help function be called if the first argument is empty. Accepted values: 'y' or 'n'.
# $@: all command line arguments.
help_call_help_function() {
	local help_function_name="$1"
	local help_if_empty="$2"
	shift
	shift

	if [[ "$help_if_empty" == 'y' && "$1" == '' ]]; then
		"$help_function_name"
		exit 1
	fi

	if [[ "$1" == '--help' || "$1" == '-h' || "$1" == 'help' ]]; then
		"$help_function_name"
		exit 0
	fi
}
