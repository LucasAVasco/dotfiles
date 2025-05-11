#!/bin/bash
#
# Configure gThumb to be the default application of all its supported mime types

gthum_mimetypes=$(grep 'MimeType' /usr/share/applications/org.gnome.gThumb.desktop | cut -d= -f2 | tr ';' ' ')

xdg-mime default org.gnome.gThumb.desktop ${gthum_mimetypes}
