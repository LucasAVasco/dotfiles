#!/bin/bash
#
# Dialog library. Supports both TUI and Rofi as user interface, depending on the environment.

# Checks if the current shell is interactive.
if [[ "$INTERACTIVE_SHELL" == y ]]; then
	__dialog_is_in_tty='y'
else
	__dialog_is_in_tty='n'
fi

# Sources the appropriate UI library
if [[ $__dialog_is_in_tty == 'y' ]]; then
	source ~/.config/bash/libs/dialog/tui.sh
else
	source ~/.config/bash/libs/dialog/rofi.sh
fi

# Ask a yes/no question.
#
# $1: The question to ask.
# $2: The default value ('y' or 'n').
#
# Return 'y' or 'n'.
dialog_ask_boolean() {
	if [[ $__dialog_is_in_tty == 'y' ]]; then
		dialog_tui_ask_boolean "$@"
	else
		dialog_rofi_ask_boolean "$@"
	fi
}

# Ask a question to the user.
#
# $1: The question to ask.
#
# Return the user response.
dialog_ask_input() {
	if [[ $__dialog_is_in_tty == 'y' ]]; then
		dialog_tui_ask_input "$@"
	else
		dialog_rofi_ask_input "$@"
	fi
}
