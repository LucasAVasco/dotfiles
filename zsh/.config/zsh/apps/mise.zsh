# Does not run this scripts if the user can not install external software
[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ] && return

if [[ -f ~/.local/bin/mise ]]; then
	eval "$(~/.local/bin/mise activate zsh)"
else
	# Activate 'mise' when it is installed
	add-zsh-hook precmd __try_activate_mise
	__try_activate_mise() {
		[[ -f ~/.local/bin/mise ]] && eval "$(~/.local/bin/mise activate zsh)"
		add-zsh-hook -d precmd __try_activate_mise # Remove the hook
	}
fi
