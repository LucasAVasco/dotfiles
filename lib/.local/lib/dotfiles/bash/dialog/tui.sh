#!/bin/bash
#
# Dialog library with TUI as the default user interface.

source ~/.local/lib/dotfiles/bash/security/external_software.sh

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

# Ask a selection question to the user.
#
# $1: The question to ask.
# $2..n: The options to choose.
#
# Return the user response or an empty string if no option is selected.
dialog_tui_ask_selection() {
	local question="$1"

	if [[ $security_external_software_allowed == y ]]; then
		gum choose --header="$question" "${@:2}" || return 0
	else
		local -a options=("${@:2}")

		# Asks the question to the user
		echo -en "\n$question:\n" >&2

		for ((i=0; i<${#options[@]}; i++)); do
			printf "[%s] %s\n" "$((i+1))" "${options[$i]}" 1>&2
		done

		# Reads the user response
		read -r user_response

		# If the user response is empty, the operation is aborted, but does not return an error
		if [[ -z "$user_response" ]]; then
			return 0
		fi

		# Validates the user response (only numbers are allowed)
		if [[ ! $user_response =~ ^[0-9]+$ ]]; then
			echo -ne "\nInvalid answer '$user_response'.!" 1>&2
			return 1
		fi

		local response="${options[$((user_response-1))]}"

		# Checks if the user selected a valid option.
		# NOTE(LucasAVasco): if the index is '0', it returns the last element, even if '0' is not a valid option. We need to check if the
		# response is '0'
		if [[ -z "$response" || "$user_response" == 0 ]]; then
			echo -ne "\nThere is no option '$user_response'." 1>&2
			return 1
		fi

		printf '%s' "$response"
	fi
}
