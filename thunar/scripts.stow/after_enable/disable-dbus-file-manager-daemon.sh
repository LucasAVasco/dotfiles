#!/bin/bash
#
# Disables the Thunar implementation of the FileManager1 D-Bus interface. I use a custom interface that uses the default applications (see
# its implementation at ~/.local/dev/default-file-manager-dbus/).

if command -v thunar >/dev/null 2>&1; then
	systemctl --user stop thunar.service
	systemctl --user mask thunar.service
fi
