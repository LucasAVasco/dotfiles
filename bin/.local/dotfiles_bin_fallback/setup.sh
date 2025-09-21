#!/bin/bash
#
# Setup the fallback executables.
#
# The fallback executables are symbolic links to the `./install.sh` script that handles the installation of the packages. See this script
# for further details.

# Only runs this script if the user is allowed to install external software
[[ "$ALLOW_EXTERNAL_SOFTWARE" != "y" ]] && {
	notify-send --app-name='Fallback Installer' 'Fallback Installer' 'You are not allowed to install external software.'
}

# Directory with some final binaries
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
mkdir -p "$current_dir/bin"

# Create the directory that holds the fallback executables
build_dir="$current_dir/build/"
created_scripts_dir="$build_dir/installers/"
test -d "$build_dir" && trash "$build_dir"
mkdir -p "$created_scripts_dir"

# Fallback executables creation
for installation_script in "$current_dir"/packages/*.sh; do
	chmod +x "$installation_script"

	executable_name=$(basename "$installation_script")
	executable_name="${executable_name%.*}"

	ln -s "../../install.sh" "$created_scripts_dir/$executable_name"
done
