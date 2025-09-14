# Zsh completions configuration

# Does not run this scripts if the user can not install external software
[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ] && return

# Path to install custom completion files (not tracked by git)
local new_path=~/.local/share/zsh_completions
fpath=("$new_path" $fpath)
if ! [[ -d "$new_path" ]]; then
	mkdir -p "$new_path"
fi
unset new_path

# Path with custom completion files (tracked by git)
fpath=(~/.local/dotfiles_share/completions/zsh/ $fpath)
