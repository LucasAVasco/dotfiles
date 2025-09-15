#!/bin/sh
#
# Install Bash. Works with several package managers.

set -e

if [ -f /usr/bin/apt -o -f /sbin/apt ]; then
	apt update
	apt upgrade -y
	apt install -y bash

elif [ -f /usr/bin/pacman -o -f /sbin/pacman ]; then
	pacman -Syu bash

elif [ -f /usr/bin/apk -o -f /sbin/apk ]; then
	apk add bash
fi
