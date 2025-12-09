#!/bin/bash
#
# Markdown functions.

source "$REPO_DIR/libs/security.sh"

# Formats a markdown input to be displayed in a terminal.
#
# $stdin: The input to format.
#
# Returns the formatted input.
markdown_format() {
	if [[ $(security_check_can_use_external_software) == y ]]; then
		gum format
	else
		cat '/dev/stdin'
	fi
}
