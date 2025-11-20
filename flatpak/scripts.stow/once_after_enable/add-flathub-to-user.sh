#!/bin/bash
#
# Add the flathub repositories to the list of repositories for the user.

[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ] && exit

# From the official arch wiki documentation at 'https://wiki.archlinux.org/title/Flatpak':
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
