#!/bin/bash
#
# Install themes.

set -e

local_themes_folder=~/.local/share/themes/

# source ~/.config/bash/libs/wget.sh
source "$MY_BASH_LIBS/wget.sh"

# Install a theme  from the Wget download directory.
#
# Automatically append '-auto-installed' to the folder to save the theme. The user should provide the theme folder name without it.
#
# $1: folder with the theme package (relative to the download directory).
# $2: name of the theme folder to install.
install_theme_from_wget() {
	local src_dir="$1"
	local dest_dir="$local_themes_folder/$2-auto-installed"

	[[ -d "$dest_dir" ]] && rm -r "$dest_dir" # Remove old theme folder
	wget_export_files "$src_dir" "$dest_dir"
}

wget_init

# Orchis GTK theme
wget_download 'https://raw.githubusercontent.com/vinceliuice/Orchis-theme/refs/heads/master/release/Orchis.tar.xz' orchis.tar.xz
wget_untar_file 'orchis.tar.xz' 'orchis'
install_theme_from_wget	'orchis/Orchis' 'Orchis'
