#!/bin/bash
#
# Library to download Git repositories and files from Git repositories to a temporary directory.
#
# You must call the `git_download_init()` function before any other function.
#
# Dependencies:
#
# * Bash
# * Git

__git_download_dir=''

# You must call this function before use any other function.
install_git_init() {
	__git_download_dir=$(mktemp -d /tmp/git_download-tmp-XXXXX)
	trap "rm -rf '$__git_download_dir'" EXIT
}

# Get the absolute path of a file in the download directory.
#
# $1..n: file name.
# Return string with the absolute path.
install_git_get_abs_path() {
	echo -n "$__git_download_dir/$@"
}

# List the files of a subdirectory of the download directory.
#
# $1: subdirectory path (relative to the download directory).
# $2: arguments append to the `ls` command.
# Return list of files (like the one returned by the `ls` command).
install_git_list_files() {
	local base_dir=$(install_git_get_abs_path "$1")
	ls "$base_dir" "${@:2}"
}

# Clone a repository into the temporary folder.
#
# $1: repository URL
# $2: clone into this directory
# $3: branch to download. A empty string means the repository default branch.
# $4..n: arguments to `git clone`
install_git_clone() {
	local source_url="$1"
	local dest_dir="$2"
	local branch="$3"

	if [[ -z "$dest_dir" ]]; then
		# Use the repository name as destination directory if the user does not provide one
		dest_dir=$(basename "$source_url")
	fi

	dest_dir=$(install_git_get_abs_path "$dest_dir")

	if [[ -z "$branch" ]]; then
		git clone "$source_url" "$dest_dir" --depth=1 "${@:4}"
	else
		git clone "$source_url" "$dest_dir" --depth=1 --branch="$branch" "${@:4}"
	fi
}

# Run a arbitrary command on the download directory.
#
# $@: command and its arguments.
install_git_run() {
	cd "$__git_download_dir"
	"$@"
	cd -
}

# Copy files from the download directory to a folder or file outside it.
#
# $1..n-1: Files to copy (relative to the download directory).
# $n: Absolute path of the destination or folder or file. Copy the files to this folder.
install_git_export_files() {
	local -a abs_files
	local dest_dir="${@:$#}"

	local num_files=$(($# - 1))
	for file_path in "${@:1:$num_files}"; do
		abs_files+=($(install_git_get_abs_path "$file_path"))
	done

	mkdir -p "$(dirname "$dest_dir")" # Ensures the installation directory exists
	cp -r "${abs_files[@]}" "$dest_dir"
}
