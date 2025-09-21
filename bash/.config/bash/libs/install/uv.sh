#!/bin/bash
#
# Module to install Python tools with uv.

# Calla `uv tool` command.
#
# $1: tool sub-command.
# $2..n: tool sub-command arguments
install_uv_call_tool() {
	local sub_command="$1"

	uv tool "$sub_command" "${@:2}"
}

# Install a tool with uv.
#
# $1: tool name.
install_uv_install_tool() {
	install_uv_call_tool install "$1"
}

# Remove a tool with uv.
#
# $1: tool name.
install_uv_remove_tool() {
	install_uv_call_tool uninstall "$1"
}
