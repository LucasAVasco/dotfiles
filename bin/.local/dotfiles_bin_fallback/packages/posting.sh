#!/bin/bash
#
# Install Posting API client (https://github.com/darrenburns/posting)

set -e

source ~/.config/bash/libs/install/uv.sh

case "$1" in
	i | u)
		install_uv_install_tool posting
		;;

	r)
		install_uv_remove_tool posting
		;;
esac
