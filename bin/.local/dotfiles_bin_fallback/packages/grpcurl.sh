#!/bin/bash
#
# gRPCurl (https://github.com/fullstorydev/grpcurl) package.

set -e

source ~/.config/bash/libs/install/go.sh

version=latest

case "$1" in
	i | u)
		install_go_install_package "github.com/fullstorydev/grpcurl/cmd/grpcurl@$version"
		;;

	r)
		install_go_remove_package grpcurl
		;;
esac
