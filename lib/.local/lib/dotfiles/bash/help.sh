#!/bin/bash
#
# Utilities functions to manage help messages.

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

# Format the help message.
#
# stdin: help message
# stdout: help message formatted
help_msg_format() {
	# The `sed` command removes trailing new line
	cat /dev/stdin | help_msg_remove_indent | sed -z 's/\n$//'

	echo "" # Add a single new line at the end
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

	# Check if should show help
	show_help_msg='n'
	exit_status=0

	if [[ "$help_if_empty" == 'y' && "$1" == '' ]]; then
		show_help_msg='y'
		exit_status=1
	fi

	if [[ "$1" == '--help' || "$1" == '-h' || "$1" == 'help' ]]; then
		show_help_msg='y'
	fi

	# Abort if the help message should not be shown
	if [[ "$show_help_msg" == "n" ]]; then
		return
	fi

	# Show the help message
	cat /dev/stdin | help_msg_format | \
	while IFS= read -r line || [[ -n "$line" ]]; do
		if [[ "$line" =~ ^@help-eval:.* ]]; then
			eval "${line#*@help-eval:}"
		else
			printf "%s\n" "$line"
		fi
	done

	exit $exit_status
}
