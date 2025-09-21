#!/bin/bash
#
# Module to install PyPI packages and make their binaries available to the user.

__local_pypi_venv_top_dir=~/.local/share/dotfiles_bin_fallback/python_venv
__local_pypi_venv_dir="$__local_pypi_venv_top_dir/.venv"

# Automatically called by `install_pypi_package()`. You should not call this function manually
__install_pip_setup_venv() {
	if ! [[ -d "$__local_pypi_venv_dir" ]]; then
		mkdir -p "$__local_pypi_venv_top_dir"
		python -m venv "$__local_pypi_venv_dir"
	fi
}

# Install a PyPI package and make its binaries available to the user.
#
# $1: The name of the package to install.
# $2..n: The names of the binaries to make available to the user.
pip_install_package() {
	__install_pip_setup_venv
	source "$__local_pypi_venv_top_dir/.venv/bin/activate"

	# Installation
	pip install "$1"

	# Exposing files
	for file in "${@:2}"; do
		ln -is "$__local_pypi_venv_top_dir/.venv/bin/$file" "$DOTFILES_FALLBACK_BIN"
	done
}

# Remove a PyPI package and its binaries.
#
# $1: The name of the package to remove.
# $2..n: The names of the binaries to remove.
pip_remove_package() {
	__install_pip_setup_venv
	source "$__local_pypi_venv_top_dir/.venv/bin/activate"

	# Removing package
	pip uninstall "$1"

	# Exposed files
	for file in "${@:2}"; do
		file="$DOTFILES_FALLBACK_BIN/$file"
		test -f "$file" && rm "$file" || echo "Can not remove '$file'"
	done
}
