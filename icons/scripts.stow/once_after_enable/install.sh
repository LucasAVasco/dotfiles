#!/bin/bash
#
# Install icon themes and cursor icon themes.

set -e

local_icons_folder=~/.local/share/icons/
local_cursor_folder=~/.local/share/icons/

# source ~/.config/bash/libs/git.sh
source "$MY_BASH_LIBS/git.sh"

# source ~/.config/bash/libs/git_download.sh
source "$MY_BASH_LIBS/git_download.sh"

# source ~/.config/bash/libs/wget.sh
source "$MY_BASH_LIBS/wget.sh"

# Install a icon package from the Git download directory.
#
# Automatically append '-auto-installed' to the folder to save the icon. The user should provide the icon folder name without it.
#
# $1: folder with the icon package (relative to the download directory).
# $2: name of the icon folder to install.
install_icon_from_git() {
	local src_dir="$1"
	local dest_dir="$local_icons_folder/$2-auto-installed"

	[[ -d "$dest_dir" ]] && rm -r "$dest_dir" # Remove old theme folder
	git_download_export_files "$src_dir" "$dest_dir"
}

# Install a icon package from the Wget download directory.
#
# Automatically append '-auto-installed' to the folder to save the icon. The user should provide the icon folder name without it.
#
# $1: folder with the icon package (relative to the download directory).
# $2: name of the icon folder to install.
install_icon_from_wget() {
	local src_dir="$1"
	local dest_dir="$local_icons_folder/$2-auto-installed"

	[[ -d "$dest_dir" ]] && rm -r "$dest_dir" # Remove old theme folder
	wget_export_files "$src_dir" "$dest_dir"
}

wget_init
git_download_init

# Icon themes {{{

git_download_clone 'https://github.com/numixproject/numix-icon-theme'
install_icon_from_git numix-icon-theme/Numix Numix

git_download_clone 'https://github.com/numixproject/numix-icon-theme-circle'
install_icon_from_git numix-icon-theme-circle/Numix-Circle Numix-Circle

# }}}

# Cursor themes {{{

# Bibata cursor theme
version=$(git_get_last_version_tag 'https://github.com/ful1e5/Bibata_Cursor')
wget_download "https://github.com/ful1e5/Bibata_Cursor/releases/download/$version/Bibata-Modern-Ice.tar.xz" 'bibata-modern-ice.tar.xz'
wget_untar_file 'bibata-modern-ice.tar.xz' 'bibata-modern-ice'
install_icon_from_wget 'bibata-modern-ice/Bibata-Modern-Ice' 'Bibata-Modern-Ice'

# }}}
