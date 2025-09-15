#!/bin/bash
#
# Install user dependencies for the devcontainer be able to run my dotfiles.

set -e

# Atuin
# Source: https://docs.atuin.sh/guide/installation/
if [[ ! -d ~/.atuin ]]; then
	curl --proto "=https" --tlsv1.2 -LsSf https://github.com/atuinsh/atuin/releases/latest/download/atuin-installer.sh | sh
fi

# Navi
# Source: https://github.com/denisidoro/navi/blob/master/docs/installation.md#using-install-script
if [[ ! -f ~/.cargo/bin/navi ]]; then
	cd /tmp
	bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install)

	if [[ -f navi.tar.gz ]]; then
		rm navi.tar.gz
	fi
	cd -
fi

# Direnv
# source: https://github.com/direnv/direnv/blob/master/docs/installation.md
mkdir -p ~/.local/bin
export bin_path=~/.local/bin
curl -sfL https://direnv.net/install.sh | bash
unset bin_path

# Force prompt rebuild
source ~/.config/zsh/prompt/build.sh
