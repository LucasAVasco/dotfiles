#!/bin/bash
#
# Bash library for downloading files with `wget`. Install all files into a temporary directory. You can copy them and install in any
# directory.
#
# You must call the `wget_init()` function before any other function.
#
# Dependencies:
#
# * Bash
# * Wget
# * `tar` command (to extract files)

__wget_download_dir=''

# You must call this function before use any other function.
wget_init() {
	__wget_download_dir=$(mktemp -d /tmp/wget-tmp-XXXXX)
	trap "rm -rf '$__wget_download_dir'" EXIT
}

# Get the absolute path of a file in the download directory.
#
# $1..n: file name.
# Return string with the absolute path.
wget_get_abs_path() {
	echo -n "$__wget_download_dir/$@"
}

# List the files of a subdirectory of the download directory.
#
# $1: subdirectory path (relative to the download directory).
# $2: arguments append to the `ls` command.
# Return list of files (like the one returned by the `ls` command).
wget_list_files() {
	local base_dir="$(wget_get_abs_path "$1")"
	ls "$base_dir" "${@:2}"
}

# Download a file into the download folder.
#
# $1: source file URL
# $2: download in this file
wget_download() {
	local source_url="$1"
	local dest_file="$2"

	wget --output-document "$(wget_get_abs_path "$dest_file")" "$source_url"
}

# Move a file or directory relative to the download directory.
#
# $1: source file or directory.
# $2: destination file or directory.
wget_mv() {
	local src="$(wget_get_abs_path "$1")"
	local dest="$(wget_get_abs_path "$2")"

	mv "$src" "$dest"
}

# Extract compressed `tar` file inside the download directory.
#
# $1: file name of the compressed file (inside the download directory).
# $2: directory name of the extracted file (inside the download directory).
wget_untar_file() {
	local src_file=$(wget_get_abs_path "$1")
	local dest_dir=$(wget_get_abs_path "$2")

	mkdir -p "$dest_dir"

	tar xf "$src_file" --directory="$dest_dir"
}

# Copy files from the download directory to a folder or file outside it.
#
# $1..n-1: Files to copy (relative to the download directory).
# $n: Absolute path of the destination folder or file. Copy the files to this folder.
wget_export_files() {
	local -a abs_files
	local dest_dir="${@:$#}"

	local num_files=$(($# - 1))
	for file_path in "${@:1:$num_files}"; do
		abs_files+=($(wget_get_abs_path "$file_path"))
	done

	mkdir -p "$(dirname "$dest_dir")" # Ensures the installation directory exists
	cp -r "${abs_files[@]}" "$dest_dir"
}
