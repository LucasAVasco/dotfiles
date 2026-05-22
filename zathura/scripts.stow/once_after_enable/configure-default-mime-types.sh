#!/bin/bash
#
# Configures Zathura to be the default viewer for its supported mime types

set -euo pipefail

if ! command -v zathura >/dev/null 2>&1; then
	exit 0
fi

mimetypes=$(grep 'MimeType' /usr/share/applications/org.pwmt.zathura-pdf-mupdf.desktop | cut -d= -f2 | tr ';' ' ')
xdg-mime default org.pwmt.zathura.desktop $mimetypes
