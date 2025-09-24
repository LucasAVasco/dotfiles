#!/bin/bash
#
# Mermaid CLI (https://github.com/mermaid-js/mermaid-cli) package.

set -e

source ~/.config/bash/libs/install/node.sh

case "$1" in
	i | u)
		install_node_install_package '@mermaid-js/mermaid-cli'
		;;

	r)
		install_node_remove_package '@mermaid-js/mermaid-cli'
		;;
esac
