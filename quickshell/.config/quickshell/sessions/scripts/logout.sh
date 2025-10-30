#!/bin/bash
#
# Logout the current session (desktop environment).

if [[ -n "$CUSTOM_DESKTOP_LOGOUT_COMMAND" ]]; then
	bash -c "$CUSTOM_DESKTOP_LOGOUT_COMMAND"
fi
