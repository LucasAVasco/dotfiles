#!/bin/bash
#
# General functions to use in custom scripts

source ~/.config/bash/libs/log.sh

scripts_current_script="$CUSTOM_SCRIPT_CURRENT_SCRIPT"
scripts_current_script_dir="$CUSTOM_SCRIPT_CURRENT_SCRIPT_DIR"
scripts_invoke_dir="$CUSTOM_SCRIPT_INVOKE_DIR"

# Change the directory to the one that the user was when the CLI was called
scripts_cd_to_invoke_dir() {
	cd "$CUSTOM_SCRIPT_INVOKE_DIR"
}

# Log an info message.
#
# $1: message.
#
# stdout: formatted message.
scripts_log_info() {
	log_info "$@"
}

# Log an error message and exit with an error code.
#
# $1: message.
# $2: error code. Optional. Default: 1
#
# stdout: formatted message.
scripts_log_error() {
	log_error "$@"
}
