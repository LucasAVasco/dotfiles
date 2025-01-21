#!/bin/bash
#
# Setup script to complete my Yazi configuration. Installs the plugins and flavors, and generates the missing files required to configure
# Yazi

# Ensures the user can install external software
[[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ]] && exit

yazi_config_dir=~/.config/yazi/
yazi_flavor_dir="$yazi_config_dir/flavors"
yazi_plugin_dir="$yazi_config_dir/plugins"

# Install packages (plugins and flavors)
if [[ ! -d "$yazi_plugin_dir" || ! -d "$yazi_flavor_dir" ]]; then
	notify-send 'Yazi setup' 'Installing flavors and plugins'
	ya pack -i

	# Ensures the next call to this script will not re-install the packages
	mkdir -p "$yazi_plugin_dir" "$yazi_flavor_dir"
fi

# LS colors installation. I could not install it with `ya pack`
[[ -d "$yazi_flavor_dir/ls-colors.yazi" ]] || git clone https://github.com/Mellbourn/ls-colors.yazi "$yazi_flavor_dir/ls-colors.yazi"

# Generates the './theme.toml' file from './base_theme.toml' and LS Colors
theme_file="$yazi_config_dir/theme.toml"
ls_colors_theme="$yazi_flavor_dir/ls-colors.yazi/theme.toml"
base_theme_file="$yazi_config_dir/base_theme.toml"

if [[ ! -f "$theme_file" || "$base_theme_file" -nt "$theme_file" || "$ls_colors_theme" -nt "$theme_file" ]]; then
	notify-send 'Yazi setup' 'Generating "theme.toml"'

	cat "$base_theme_file" "$ls_colors_theme" > "$theme_file"
fi
