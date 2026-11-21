#!/bin/bash
#
# Creates a D-Bus service that implements the FileManager1 interface. It handles all files by opening it with `default_open` and folders by
# opening it with `default_file_manager`

source ../../../.lib/strict.sh

mkdir -p ~/.local/share/dbus-1/services/

cat <<-EOF > ~/.local/share/dbus-1/services/org.freedesktop.FileManager1.service
	[D-BUS Service]
	Name=org.freedesktop.FileManager1
	Exec=/home/$USER/.local/dev/default-file-manager-dbus/run.sh
EOF
