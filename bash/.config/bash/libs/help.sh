#!/bin/bash
#
# Utilities functions to manage help messages.

# Format help message.
#
# $1: indentation to remove from the help message. A `sed` regex
# stdin: help message
# stdout: help message formatted
help_msg_format() {
	sed "s/^$1//g"
}
