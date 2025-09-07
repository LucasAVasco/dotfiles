#!/bin/bash
#
# Library to automatically type text.

# Send a command to the auto-type script.
#
# $@: command to send to the auto-type script.
#
# Returns the output of the script.
linux_keyboard_auto_type() {
	~/.config/keyboard/type.sh "$@"
}
