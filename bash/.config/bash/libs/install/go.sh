#!/bin/bash
#
# Module to install Golang packages.

# Install a go package. Requires Go to be installed to work.
#
# $1: go package to install.
install_go_package() {
	package="$1"
	go install "$package"
}
