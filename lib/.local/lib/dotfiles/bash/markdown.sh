#!/bin/bash
#
# Markdown functions.

source ~/.local/lib/dotfiles/bash/security/external_software.sh

# Formats a markdown input to be displayed in a terminal.
#
# $stdin: The input to format.
#
# Returns the formatted input.
markdown_format() {
	if [[ $security_external_software_allowed == y ]]; then
		gum format
	else
		cat '/dev/stdin'
	fi
}
