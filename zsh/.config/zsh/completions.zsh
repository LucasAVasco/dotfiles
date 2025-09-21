# Zsh completions configuration

# Does not run this scripts if the user can not install external software
[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ] && return

# Path to install custom completion files (not tracked by git)
local new_path=~/.local/share/zsh_completions
fpath=("$new_path" $fpath)
if ! [[ -d "$new_path" ]]; then
	mkdir -p "$new_path"
fi

# Path with custom completion files (tracked by git)
local new_path=~/.local/dotfiles_share/completions/zsh/
if ! [[ -d "$new_path" ]]; then
	echo "Creating custom ZSH completions files at '$new_path'\n"
	source ~/.local/dotfiles_share/completions/update-zsh-completions.zsh
fi

fpath=("$new_path" $fpath)
unset new_path
