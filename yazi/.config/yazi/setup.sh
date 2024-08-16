#!/bin/env bash
#
# Setup script to complete the Yazi configuration. Downloads the plugins and flavors, and generate the missing files required to configure
# Yazi


yazi_config_dir=~/.config/yazi/


# Functions {{{

# Get the name of a Git repository.
# $1: Repository URL
# $2: Optional overriding value. Returns this value if provided
get_repository_name() {
	name="$2"

	if [[ -z "$name" ]]; then
		name=${1##*/}  # Removes anything before a '/' character
		name=${name%.git}  # Removes the '.git' suffix
	fi

	echo "$name"
}


# Download a Git repository.
# $1: Download the Git repository inside this folder
# $2: Repository URL
# $3: Overrides the installation directory. Path relative to "$1"
install_git_repository() {
	repository_name=$(get_repository_name "$2" "$3")
	installation_dir="$yazi_config_dir/$1/$repository_name"

	# Does not install more than once
	if [[ -d "$installation_dir" ]]; then
		return
	fi

	# Ensures the parent folder existis
	mkdir -p `dirname "$installation_dir"`

	# Installation
	echo -e "Installing \e[1;31m${2}\e[1;0m inside \e[1;33m${installation_dir}\e[1;0m"
	git clone "$2" "$installation_dir"
}


# Download a Yazi plugin.
# Install a Git repository inside './plugins/'
# $1: repository URL
# $2: Overrides the installation directory. Path relative to './plugins/'
download_plugin() {
	install_git_repository 'plugins' "$1" "$2"
}

# Download a Yazi flavor.
# Install a Git repository inside './flavors/'
# $1: repository URL
# $2: Overrides the installation directory. Path relative to './flavors/'
download_flavor() {
	install_git_repository 'flavors' "$1" "$2"
}

# }}}


# Themes
download_flavor 'https://github.com/BennyOe/tokyo-night.yazi'
download_flavor 'https://github.com/Mellbourn/ls-colors.yazi'

# Generates the './theme.toml' file from './base_theme.toml' and LS Colors
theme_file="$yazi_config_dir/theme.toml"
base_theme_file="$yazi_config_dir/base_theme.toml"


if [[ ! -f  "$theme_file" || "$base_theme_file" -nt "$theme_file" ]]; then
	ls_colors="$yazi_config_dir/flavors/ls-colors.yazi/theme.toml"

	cat "$base_theme_file" "$ls_colors" > "$theme_file"
fi
