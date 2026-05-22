#!/bin/bash
#
# Set Firefox as the default web browser.

set -eof pipefail

if ! command -v firefox >/dev/null 2>&1; then
	echo "Can not set Firefox as the default web browser: firefox is not installed."
	exit
fi

xdg-settings set default-web-browser firefox.desktop
