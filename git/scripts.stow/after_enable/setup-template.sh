#!/bin/bash
#
# Creates the template to use for Git repositories.

temp_dir=$(mktemp -d)
trap "rm -r $temp_dir" EXIT
cd "$temp_dir"

# Initializes an repository without the default templates
git init --template=

# Installs Git LFS
git lfs install --local

# Setups default lefthook hooks
cp ~/.config/git/hooks/lefthook.yml lefthook-local.yml
lefthook install

# Replaces existing hooks by the new ones
if [[ -d ~/.config/git/template/hooks ]]; then
	trash ~/.config/git/template/hooks
fi

mkdir -p ~/.config/git/template/
cp -r ./.git/hooks ~/.config/git/template/hooks
