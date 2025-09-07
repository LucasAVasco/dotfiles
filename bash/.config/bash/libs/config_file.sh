#!/bin/bash
#
# Library to manage configuration files. The file format must be based on 'key/values' pairs separated by a separator like '=' or ':'.

# Set a key in a configuration file.
#
# $1?: configuration file path. Optional. If not provided (empty string), use the content of the standard input.
# $2: separator between the key name and the key value in the configuration file.
# $3: key name.
# $4: value to set.
# stdin?: content of the configuration file. Only provided if the configuration file is not provided as an argument.
#
# stdout?: the content of the configuration file with the new value. Only provided if the configuration file is not provided as an argument.
config_file_set_key_value() {
	local config_file="$1"
	local separator="$2"
	local key="$3"
	local value="$4"

	# If the configuration file has the expected key
	if [[ -n $(grep "$key *$separator.*" "$config_file") ]]; then
		local has_key=y
	else
		local has_key=n
	fi

	# Set the key on the configuration file
	if [[ $has_key == y ]]; then
		if [[ -n "$config_file" ]]; then
			sed -i "s/$key *$separator.*/$key$separator$value/" "$config_file"
		else
			sed "s/$key *$separator.*/$key$separator$value/"
		fi
	else
		if [[ -n "$config_file" ]]; then
			echo -en "\n$key$separator$value" >> "$config_file"
		else
			echo -en "\n$key$separator$value"
		fi
	fi
}
