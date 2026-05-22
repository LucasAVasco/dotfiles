#!/bin/bash
#
# Add the flathub repositories to the list of repositories for the user.

set -eof pipefail

[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ] && exit

if ! command -v flatpak >/dev/null 2>&1; then
	echo "can not add flathub remote: flatpak is not installed"
	exit
fi

# From the official arch wiki documentation at 'https://wiki.archlinux.org/title/Flatpak':
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
