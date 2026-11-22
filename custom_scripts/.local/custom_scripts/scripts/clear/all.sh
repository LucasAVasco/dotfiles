#!/bin/bash
#
# Clear all non-essential data (e.g. cache, and sessions information) from the system. They are trashed instead of removed, so you can
# recover them with the 'trash-restore' command. If you want to permanently remove them, use the 'trash-empty' command after running this
# script

source ~/.local/lib/dotfiles/bash/strict.sh

source ~/.local/lib/dotfiles/bash/dialog/dialog.sh
source ~/.local/lib/dotfiles/bash/log.sh
source ~/.local/lib/dotfiles/bash/markdown.sh

shopt -s nullglob # Allow globs that results in no entry

if [[ $(dialog_ask_boolean 'Clear all data from the system?' n) == n ]]; then
	echo 'Aborted' >&2
	exit 1
fi

# Trash files if they exist. Show the files that were trashed on stdout. Ignore errors
try_trash_with_debug() {
	log_info "Trashing $*"

	# List all files that exist
	existing_files=()
	for file_path in "$@"; do
		if [[ -e "$file_path" ]]; then
			existing_files+=("$file_path")
		fi
	done

	if [[ ${#existing_files[@]} -eq 0 ]]; then
		log_info 'No files to trash'
		return
	fi

	trash "${existing_files[@]}"
}

shopt -s nullglob # Without this, the globbing will raise an error when there are no files to trash

# Log files
log_info 'Clearing lnav sessions'
try_trash_with_debug ~/.config/lnav/view-info-*.json ~/.config/lnav/crash/*.log ~/.config/lnav/log_metadata.db

# Text editors
log_info 'Clearing neovim files'
try_trash_with_debug ~/.local/state/nvim/lsp.log ~/.nvim/.undo_files ~/.nvim/.backup_files ~/.nvim/.swap_files ~/.local/share/vifm/Trash

log_info 'Clearing vifm cache'
rm ~/.cache/vifm/thumbnail.*.jpg
rm rm ~/.cache/vifm/ueberzug-*

# Containers
log_info 'Clearing podman cache'
podman system prune --all && podman volume prune

log_info 'Clearing docker cache'
docker system prune --all && docker volume prune

# Node packages
log_info 'Clearing npm cache'
npm cache clean --force
try_trash_with_debug ~/.npm/_npx\n

log_info 'Clearing yarn cache'
yarn cache clean --all

log_info 'Clearing pnpm cache'
pnpm store prune

if [[ $(dialog_ask_boolean 'Empty trash long than 6 mounts ago?' n) == y ]]; then
	trash-empty 180
fi
