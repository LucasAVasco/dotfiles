#!/bin/bash
#
# Module to manager string.

# Check if a string has a sub-string.
#
# $1: string.
# $2: sub-string.
#
# Return 'y' if the string has the sub-string, 'n' otherwise.
string_has_substring() {
	local string="$1"
	local substring="$2"

	[[ "$string" == *"$substring"* ]] && echo y || echo n
}

# Check if a string has a regex.
#
# $1: string.
# $2: Bash regex.
#
# Return 'y' if the string has the regex, 'n' otherwise.
string_has_regex() {
	local string="$1"
	local pattern="$2"

	[[ "$string" =~ $pattern ]] && echo y || echo n
}
