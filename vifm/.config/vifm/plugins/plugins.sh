#!/bin/bash

[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ] && exit

set -e

# Execute all commands from the current directory
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

source ./libs/install.sh

# Plugins installation {{{

install_plugin 'https://github.com/thimc/vifm_devicons'

install_plugin 'https://github.com/thimc/vifmimg'
mkdir -p ../scripts/plugins/vifmimg
cp ./repos/vifmimg/vifmimg ./repos/vifmimg/vifmrun ../scripts/plugins/vifmimg

# }}}

# Must be called after all plugins are installed
install_end
