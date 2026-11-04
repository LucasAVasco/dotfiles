#!/bin/bash
#
# Initialize a python project with 'mise'

source ~/.local/lib/dotfiles/bash/strict.sh

source ~/.local/proj-manager/libs/package_fs.sh
source ~/.local/proj-manager/libs/package_run.sh
source ~/.local/lib/dotfiles/bash/dialog/dialog.sh
source ~/.local/lib/dotfiles/bash/config_var.sh

# Initial 'mise.toml'
package_fs_cp ./.gitignore ./
package_fs_cp ./mise.toml ./pylsp-mypy.cfg ./pyproject.toml ./

# Project configuration
package_cd_to_invoke_dir
project_name=$(dialog_ask_input "Project name")
description=$(dialog_ask_input "Project description")
repository_name=$(dialog_ask_input "Repository name")
python_version="$(mise latest python)"
git_user_name=$(git config --global user.name)
if [[ $(dialog_ask_boolean "Use ${git_user_name} as Git user name?" y) == n ]]; then
	git_user_name=$(dialog_ask_input "Git user name")
fi
author_name="$git_user_name"
if [[ $(dialog_ask_boolean "Use ${author_name} as author?" y) == n ]]; then
	author_name=$(dialog_ask_input "Author name")
fi
author_email=$(git config --global user.email)
if [[ $(dialog_ask_boolean "Use ${author_email} as author email?" y) == n ]]; then
	author_email=$(dialog_ask_input "Author email")
fi

config_var_set_in_file 'pyproject.toml' \
	project-name "$project_name" \
	author-name "$author_name" \
	author-email "$author_email" \
	description "$description" \
	python-version "$python_version" \
	python-version-major "$(echo "$python_version" | cut -d '.' -f 1)" \
	git-user-name "$git_user_name" \
	repository-name "$repository_name"

# Update the versions
package_run_provider update-proj/mise/version
package_run_provider update-proj/mise/python/version
