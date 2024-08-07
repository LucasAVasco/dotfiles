#!/bin/bash
#
# Install some nerd fonts inside the '$fonts_folder' folder. Use the `download_font()` function to install the desired fonts


version=v3.2.1                       # Version of the fonts
fonts_folder=~/.fonts/auto_installed # Install the fonts inside this folder


# Download the zipped fonts inside this folder
tmp_dir=$(mktemp --directory /tmp/tmp.fonts.XXXXXXXX)
trap "rm -r '${tmp_dir}'" EXIT


# Install a nerd font
#
# Download from the GitHub repository. The fount will be installed inside a sub-folder in the '$fonts_folder' directory
#
# $1: Fount name. You can get it at 'https://www.nerdfonts.com/font-downloads'. Place the mouse on top of the download button of the desired
# font. This will show the zipped file to be downloaded. You need to provide the file name of this URL (without the '.zio' extension)
# $2: Version of the font to download
download_font () {
	# Folder to hold this specific font
	install_folder="$fonts_folder/$1"
	mkdir -p "$install_folder"

	# Download, extract and install
	curl --location "https://github.com/ryanoasis/nerd-fonts/releases/download/${2}/${1}.zip" --output "${tmp_dir}/font.zip"
	unzip "${tmp_dir}/font.zip" -d "$install_folder"

	# Log message
	echo -e "\n\e[1;32m'$1' version '$2' Installed\e[1;0m"
}


# Removes old fonts
rm -r "$fonts_folder" 2> /dev/null

# Installs the desired fonts
download_font Hack $version
