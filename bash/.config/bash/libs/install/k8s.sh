#!/bin/bash
#
# Library to install Kubernetes plugins.

# Install a plugin.
#
# $1: plugin name.
install_k8s_install_plugin() {
	kubectl krew install "$1"
}
