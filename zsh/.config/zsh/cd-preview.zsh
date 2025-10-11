autoload -U add-zsh-hook

__my_cd_preview_last_path="$PWD" # Starts as the current directory to avoid calling dir-preview when opening the shell

add-zsh-hook preexec __my_cd_preview_preexec
__my_cd_preview_preexec() {
	__my_cd_preview_last_path="$PWD"
}

add-zsh-hook precmd __my_cd_preview_precmd
__my_cd_preview_precmd() {
	if [[ "$__my_cd_preview_last_path" != "$PWD" ]]; then
		dir-preview "$PWD"
	fi
}
