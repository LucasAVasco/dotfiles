#!/bin/bash
#
# Configure gThumb to be the default application of all its supported mime types

set -eof pipefail

if ! command -v gthumb >/dev/null 2>&1; then
	exit 0
fi

mimetypes=$(grep 'MimeType' /usr/share/applications/org.gnome.gThumb.desktop | cut -d= -f2 | tr ';' ' ')
xdg-mime default org.gnome.gThumb.desktop $mimetypes
