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

# Remove the indent from a help message.
#
# To get the number of indentation that must be removed, this function checks only the first line. All other lines will be formatted using
# the indentation size of the first line
#
# You must not combine spaces and tabs in the help message. Use only one of them
#
# stdin: help message
# stdout: help message without the indent
help_msg_remove_indent() {
	local message=$(cat /dev/stdin)

	# Gets the indent size of the first line
	local first_line=$(echo "$message" | head -n 1)
	local indent="${first_line%%[^$'\t' ]*}"
	local indent_size="${#indent}"

	# Removes the indent from all lines
	printf "%s" "$message" | sed "s/^\s\{${indent_size}\}//g"
}

# Handle a help message.
#
# Automatically print the help message if the user provided the `--help`, `-h` or `help` argument.
#
# The help message is formatted to remove the indent (see `help_msg_remove_indent()` function)
#
# stdin: help message
# $1: should the help function be called if the first argument is empty. Accepted values: 'y' or 'n'.
# $2-n: all command line arguments.
help_handle() {
	local help_if_empty="$1"
	shift

	if [[ "$help_if_empty" == 'y' && "$1" == '' ]]; then
		cat /dev/stdin | help_msg_remove_indent
		exit 1
	fi

	if [[ "$1" == '--help' || "$1" == '-h' || "$1" == 'help' ]]; then
		cat /dev/stdin | help_msg_remove_indent
		exit 0
	fi
}
