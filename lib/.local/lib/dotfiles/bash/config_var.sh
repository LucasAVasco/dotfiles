#!/bin/bash
#
# Set configuration file variables.

# Set a variable in a configuration read from standard input.
#
# stdin: the content to be changed.
# $1: name of variable 1.
# $2: value of variable 1.
# $3: name of variable 2.
# $4: value of variable 2.
# ...
#
# Outputs the new configuration with the variables replaced.
config_var_set() {
	local args=()
	local is_name=y
	for arg in "$@"; do
		if [[ "$is_name" == y ]]; then
			args+=("<var:$arg>")
			is_name=n
		else
			args+=("$arg")
			is_name=y
		fi
	done

	strsubst "${args[@]}"
}

# Set a variable in a configuration file (automatically updates the file).
#
# $1: file path.
# $2: name of variable 1.
# $3: value of variable 1.
# $4: name of variable 2.
# $5: value of variable 2.
# ...
config_var_set_in_file() {
	local file_path="$1"
	shift

	config_var_set "$@" < "$file_path" | sponge "$file_path"
}
