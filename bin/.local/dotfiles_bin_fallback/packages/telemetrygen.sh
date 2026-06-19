#!/bin/bash
#
# telemetrygen (https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/cmd/telemetrygen/) package.

set -e

source ~/.local/lib/dotfiles/bash/install/go.sh

version=latest

case "$1" in
	i | u)
		install_go_install_package "github.com/open-telemetry/opentelemetry-collector-contrib/cmd/telemetrygen@$version"
		;;

	r)
		install_go_remove_package telemetrygen
		;;
esac
