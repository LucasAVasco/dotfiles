#!/bin/bash
#
# Mermaid CLI (https://github.com/mermaid-js/mermaid-cli) package.

set -e

source ~/.local/lib/dotfiles/bash/install/node.sh

# NOTE(LucasAVasco): mermaid-cli requires a specific version of chrome-headless-shell. You need to run it and check the error message to get
# the correct version
mermaid_cli_version='11.15.0'
chrome_headless_shell_version='148.0.7778.97'

case "$1" in
	i | u)
		install_node_install_package "@mermaid-js/mermaid-cli@$mermaid_cli_version"
		pnpx puppeteer browsers install "chrome-headless-shell@$chrome_headless_shell_version"
		;;

	r)
		install_node_remove_package '@mermaid-js/mermaid-cli'
		;;
esac
