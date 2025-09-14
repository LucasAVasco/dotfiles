#!/bin/bash
#
# Set Qutebrowser as the default web browser

# Does not run this script if the user can not install external software
[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ] && exit 0

xdg-settings set default-web-browser org.qutebrowser.qutebrowser.desktop
