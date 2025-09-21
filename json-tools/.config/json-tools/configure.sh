#!/bin/bash
#
# INFO(LucasAVasco):This script must be sourced, not executed.

# Paths
export LUA_PATH="$HOME/.config/json-tools/build/src/?.luac;$LUA_PATH"

# First setup
if [[ ! -d "$HOME/.config/json-tools/build/" ]]; then
	~/.config/json-tools/setup.sh >&2
fi
