#!/bin/bash
#
# Install some nerd fonts inside the '$fonts_folder' folder. Use the `download_font()` function to install the desired fonts


nerdfonts_version=v3.3.0             # Version of the fonts from Nerd Fonts
google_emoji_version=v2.047          # Version of the Google's Emoji Fonts
fonts_folder=~/.fonts/auto_installed # Install the fonts inside this folder


# Download the zipped fonts inside this folder
tmp_dir=$(mktemp --directory /tmp/tmp.fonts.XXXXXXXX)
trap "rm -r '${tmp_dir}'" EXIT


# Install a nerd font
#
# Download from the GitHub repository. The font will be installed inside a sub-folder in the '$fonts_folder' directory
#
# $1: Fount name. You can get it at 'https://www.nerdfonts.com/font-downloads'. Place the mouse on top of the download button of the desired
# font. This will show the zipped file to be downloaded. You need to provide the file name of this URL (without the '.zio' extension)
# $2: Version of the font to download
download_font () {
	# Folder to hold this specific font
	install_folder="$fonts_folder/$1"

	# Download
	curl --location "https://github.com/ryanoasis/nerd-fonts/releases/download/${2}/${1}.zip" --output "${tmp_dir}/font.zip"

	# (Re)Installation
	rm -r "$install_folder" 2> /dev/null
	mkdir -p "$install_folder"
	unzip "${tmp_dir}/font.zip" -d "$install_folder"

	# Log message
	echo -e "\n\e[1;32m'$1' version '$2' Installed\e[1;0m"
}

# Install Google's Noto Emoji fonts
#
# Download from the GitHub repository. The font will be installed inside a sub-folder in the '$fonts_folder' directory
#
# $2: Version of the font to download
download_emoji_font() {
	# Folder to hold this specific font
	install_folder="$fonts_folder/google-noto-emoji"

	# Download
	curl --location "https://codeload.github.com/googlefonts/noto-emoji/zip/refs/tags/$1" --output "$tmp_dir/emoji.zip"
	rm -r "$tmp_dir/emoji"
	unzip "$tmp_dir/emoji.zip" -d "$tmp_dir/emoji"

	# (Re)Installation
	rm -r "$install_folder" 2> /dev/null
	mkdir -p "$install_folder"
	mv "$tmp_dir"/emoji/noto-emoji-*/fonts/* "$install_folder"

	# Log message
	echo -e "\n\e[1;32m'Google Noto Emoji' version '$2' Installed\e[1;0m"
}

# Installs the desired fonts
download_font Hack $nerdfonts_version
download_font JetBrainsMono $nerdfonts_version
download_emoji_font $google_emoji_version
