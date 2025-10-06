#!/bin/bash
#
# Uninstall the automatically installed fonts

installation_folder=~/.fonts/auto_installed/
if [[ -d "$installation_folder" ]]; then
	rm -r  2> /dev/null
fi
