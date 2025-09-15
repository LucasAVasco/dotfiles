#!/bin/bash
#
# Send all dotfiles to a devcontainer.
#
# Usage: `./send2devcontainer.sh [-f | --force] <devcontainer_id>`

set -e

source ~/.config/bash/libs/devcontainer.sh
source ~/.config/bash/libs/docker.sh

# Arguments parsing
force_update=n

while [[ 1 ]]; do
	case "$1" in
		-f | --force) force_update=y
		;;
		*)
			break
		;;
	esac

	shift
done

# Devcontainer ID
devcontainer_id="$1"

# Zsh prompt already installed
lock_file_name=".zsh-prompt-lock-file"
if [[ $(devcontainer_has_lock_file "$devcontainer_id" "$lock_file_name") == y ]] && [[ $force_update == n ]]; then
	echo 'ZSH prompt already installed. Aborting ZSH installation...'
	exit 0
fi

# Ensures Bash is installed. The `docker_get_container_user` function requires it
docker_send_file_to_container "$devcontainer_id" ~/.config/zsh/devcontainer/install-bash.sh /tmp/install-bash.sh
docker_execute_command_in_container "$devcontainer_id" 'root' /tmp/install-bash.sh

# Devcontainer user
devcontainer_user=$(docker_get_container_user $devcontainer_id)

# Sends the other dotfiles
devcontainer_sync_files "$devcontainer_id" '~/.local/dotfiles/bin/' '~/.local/dotfiles_bin/' \
	'~/.local/dotfiles/profile/' '~/.profile' \
	'~/.local/dotfiles/atuin/' '~/.config/atuin/' \
	'~/.local/dotfiles/navi/' '~/.config/navi/' \
	'~/.local/dotfiles/zsh/' '~/.zshrc' '~/.config/zsh' '~/.zsh_plugins.txt' \
	'~/.local/dotfiles/fzf/' '~/.fzfrc'

docker_execute_command_in_container "$devcontainer_id" 'root' chown -R "$devcontainer_user:$devcontainer_user" "/home/$devcontainer_user"

# Installs dependencies
docker_execute_command_in_container "$devcontainer_id" 'root' "/home/$devcontainer_user/.config/zsh/devcontainer/install-root-deps.sh"
docker_execute_command_in_container "$devcontainer_id" '' "/home/$devcontainer_user/.config/zsh/devcontainer/install-user-deps.sh"

# Configures `sudo`
docker_execute_command_in_container "$devcontainer_id" 'root' \
	"/home/$devcontainer_user/.config/zsh/devcontainer/add-user-to-sudo.sh" "$devcontainer_user"

docker_execute_command_in_container "$devcontainer_id" 'root' passwd "$devcontainer_user"

# Creates lock file
devcontainer_create_lock_file "$devcontainer_id" "$lock_file_name"
