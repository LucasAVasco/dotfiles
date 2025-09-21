#!/bin/bash
#
# detect-secrets (https://github.com/Yelp/detect-secrets) package.

set -e

source ~/.config/bash/libs/install/uv.sh

case "$1" in
	i | u)
		install_uv_install_tool detect-secrets
		;;

	r)
		install_uv_remove_tool detect-secrets
		;;
esac
