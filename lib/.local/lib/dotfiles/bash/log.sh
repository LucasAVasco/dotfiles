#!/bin/bash
#
# Logging functions.

# Log an info message.
#
# $1: message.
#
# stdout: formatted message.
log_info() {
	echo -e "\n\033[0;44m INFO \033[0m $1\n"
}

# Log an warning message.
#
# $1: message.
#
# stdout: formatted message.
log_warn() {
	echo -e "\n\033[0;43m\033[1;30m WARNING \033[0m $1\n"
}

# Log an error message and exit with an error code.
#
# $1: message.
# $2: error code. Optional. Default: 1
#
# stdout: formatted message.
log_error() {
	echo -e "\n\033[0;41m ERROR \033[0m $1\n"
	exit "${2:-1}"
}
