#!/bin/bash
#
# Setup script to complete my Yazi configuration. Installs the plugins and flavors, and generates the missing files required to configure
# Yazi

# Ensures the user can install external software
[[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ]] && exit

yazi_config_dir=~/.config/yazi/
yazi_deps_dir="$yazi_config_dir/deps"
yazi_flavor_dir="$yazi_config_dir/flavors"
yazi_plugin_dir="$yazi_config_dir/plugins"

# Install packages (plugins and flavors)
if [[ ! -d "$yazi_plugin_dir" || ! -d "$yazi_flavor_dir" ]]; then
	notify-send 'Yazi setup' 'Installing flavors and plugins'
	ya pkg install

	# Ensures the next call to this script will not re-install the packages
	mkdir -p "$yazi_plugin_dir" "$yazi_flavor_dir"
fi

# Install a Git repository as dependency (not a plugin or flavor)
install_deps() {
	flavor="$1"
	flavor_name=$(basename "$1")
	flavor_path="$yazi_deps_dir/$flavor_name.yazi"

	if [[ ! -d "$flavor_path" ]]; then
		git clone "https://github.com/$flavor.yazi" "$flavor_path"
	fi
}

install_deps 'Mellbourn/ls-colors'

# Generates the './theme.toml' file from './base_theme.toml' and LS Colors
theme_file="$yazi_config_dir/theme.toml"
ls_colors_theme_file="$yazi_deps_dir/ls-colors.yazi/theme.toml"
base_theme_file="$yazi_config_dir/base_theme.toml"

if [[ ! -f "$theme_file" || "$base_theme_file" -nt "$theme_file" || "$ls_colors_theme_file" -nt "$theme_file" ]]; then
	notify-send 'Yazi setup' 'Generating "theme.toml"'

	cat "$base_theme_file" "$ls_colors_theme_file" > "$theme_file"
fi
