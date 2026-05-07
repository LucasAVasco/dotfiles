#!/bin/bash
#
# Hermes (https://hermes-agent.nousresearch.com/) package.

set -e

case "$1" in
	i | u)
		curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
		;;

	r)
		hermes uninstall
		;;
esac
