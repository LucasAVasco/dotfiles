#!/bin/bash
#
# Dialog library with TUI as the default user interface.

source ~/.config/bash/libs/security/external_software.sh

# Ask a yes/no question.
#
# $1: The question to ask.
# $2: The default value ('y' or 'n').
#
# Return 'y' or 'n'.
dialog_tui_ask_boolean() {
	local question="$1"
	local default="$2"

	if [[ $security_external_software_allowed == y ]]; then
		test "$default" = 'y' && default='yes' || default='no'
		gum confirm --default="$default" "$question" && echo -n 'y' || echo -n 'n'

	else
		# Asks the question to the user
		echo -en "\n$question " 1>&2
		if [[ "$default" == 'y' ]]; then
			echo -n '[Y/n] ' 1>&2
		else
			echo -n '[y/N] ' 1>&2
		fi

		# Reads the user response
		read -r user_response

		# Parses the user response
		if [[ "$user_response" =~ ^[yY]$ ]]; then
			echo -n 'y'
		elif [[ "$user_response" =~ ^[nN]$ ]]; then
			echo -n 'n'
		elif [[ -z "$user_response" ]]; then
			echo -n $default

		else
			echo -ne "\nInvalid answer '$user_response'.!" 1>&2
			return 1
		fi
	fi
}

# Ask a question to the user.
#
# $1: The question to ask.
#
# Return the user response.
dialog_tui_ask_input() {
	local question="$1"

	if [[ $security_external_software_allowed == y ]]; then
		gum input --placeholder="$question"

	else
		# Asks the question to the user
		echo -en "\n$question: " 1>&2

		# Reads the user response
		read -r user_response

		# Parses the user response
		printf '%s' "$user_response"
	fi
}
