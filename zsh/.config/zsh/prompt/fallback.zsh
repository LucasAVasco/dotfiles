# Pure-ZSH fallback prompt (used when ALLOW_EXTERNAL_SOFTWARE != 'y').
# Zero forks, zero loops, zero external commands.

setopt prompt_subst

declare -i __my_zsh_theme_cmd_num=1 # Index of the current command

() {
	# Palette (mirrors src/config.rs)
	local c_base='#2a2a30'
	local c_shlvl='#cccc00'
	local c_sep='#777777'
	local c_date='#bbbb00'
	local c_cwd='#8888ff'
	local c_cmd_num='#dddddd'
	local c_arrow='#333333'
	local c_container_bg='#cc5500'
	local c_container_fg='#dddddd'
	local c_root_bg='#aa0000'
	local c_root_fg='#ffffff'

	# Powerline / Nerd Font glyphs (width 1)
	local i_lsemi='%1{%}'
	local i_rsemi='%1{%}'
	local i_lltri='%1{%}'
	local i_urtri='%1{%}'
	local i_rtri='%1{%}'

	# Main info line: [  SHLVL user   truncated_cwd ]
	local line_info=""
	line_info+="%F{${c_base}}${i_lsemi}%K{${c_base}}%F{${c_shlvl}}%1{%} %L %n "
	line_info+="%F{${c_sep}}${i_urtri}%K{${c_cwd}}${i_lltri}"
	line_info+="%F{${c_base}}%B %1{%} %(4~|%-1~/…/%2~|%~)%b"
	line_info+="%F{${c_cwd}}%k${i_rsemi}%f"

	# Optional container badge (checked once at shell startup)
	local badge_container=""
	if [[ "$RUNNING_INSIDE_CONTAINER" == 'y' ]]; then
		badge_container="%F{${c_container_bg}}${i_lsemi}%K{${c_container_bg}}%F{${c_container_fg}}%B%1{%}%b%F{${c_container_bg}}%k${i_rsemi}%f "
	fi

	# Root badge (native ZSH EUID == 0 conditional, no external `sudo` call)
	local badge_root="%(#.%F{${c_root_bg}}${i_lsemi}%K{${c_root_bg}}%F{${c_root_fg}}%B %1{󰒃%} ROOT %b%F{${c_root_bg}}%k${i_rsemi}%f .)"

	# Command number + 3-tone arrows
	local arrows=""
	arrows+="%F{${c_arrow}}${i_lsemi}%K{${c_arrow}}%F{${c_cmd_num}}\${__my_zsh_theme_cmd_num}%F{${c_arrow}} %k${i_lltri}%f  "

	typeset -gi __my_zsh_fallback_show_sep=0
	typeset -g __my_zsh_fallback_sep=$'\n'

	# Static prompt template (keeps PROMPT immutable so semantic-prompts.zsh wrapping persists)
	PROMPT='${__my_zsh_fallback_sep}'"${line_info}"$'\n\n'"${badge_container}${badge_root}${arrows}"
}

autoload -Uz add-zsh-hook

__my_zsh_fallback_preexec() {
	__my_zsh_fallback_show_sep=1
	__my_zsh_theme_cmd_num+=1

	echo ''
}

__my_zsh_fallback_precmd() {
	local err=$?

	if (( __my_zsh_fallback_show_sep )); then
		__my_zsh_fallback_show_sep=0

		local status_prefix
		if (( err == 0 )); then
			status_prefix=$'%{\e[3m%}%B%F{#00dd00} 0%b%{\e[0m%} %F{#444444}'
		else
			status_prefix=$'%{\e[3m%}%B%F{#ff2222} '"${err}"$'%b%{\e[0m%} %F{#444444}'
		fi

		local -i fill=$(( COLUMNS - 3 - ${#err} ))
		local dots=""
		(( fill > 0 )) && dots="${(l:${fill}::-:)}"

		__my_zsh_fallback_sep=$'\n\n'"${status_prefix}${dots}%f"$'\n\n'
	else
		__my_zsh_fallback_sep=$'\n'
	fi
}

add-zsh-hook preexec __my_zsh_fallback_preexec
add-zsh-hook precmd __my_zsh_fallback_precmd
