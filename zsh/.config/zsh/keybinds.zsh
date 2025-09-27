# The Oh My Zsh 'lib/key-bindings.zsh' plugin clears all previous beybinds. To effectively set the keybins, this script must be sourced
# after Oh My Zsh configuration.

#'^' is the prefix to CTRL. And '^[' is the prefix to ALT. Example: '^H' means 'CTRL-H' and '^[n' means 'ALT-n'

# Functions {{{


# Expand the aliases in the current command
#
# The expanded command can be accessed by the `full_cmd` global variable
__expand_alias() {
	full_cmd=(${=LBUFFER})

	# Expand the command name alias
	local cmd_name="${full_cmd[1]}"
	local cmd_name=$(alias "$cmd_name" | cut -d= -f2) # The content after the '=' symbol is the expanded alias

	if [[ -n "$cmd_name" ]]; then
		# Removes last and first quotes
		if [[ "${cmd_name[1]}" == "'" ]]; then
			local index_of_cmd_name_last_char=$((${#cmd_name}-2))
			cmd_name=$(echo "${cmd_name:1:$index_of_cmd_name_last_char}")
		fi

		# Replaces the new command name on the full command
		full_cmd=(${=cmd_name} ${=full_cmd:1})
	fi
}

# }}}

# Enable VI key binds. Need to be executed after Oh My Zsh and before setting the other key binds
bindkey -v

# Delete the last word with CTRL-BACKSPACE. Some terminal emulators interpret CTRL-BACKSPACE as '^H' or '^W'
bindkey '^H' backward-delete-word
bindkey '^W' backward-delete-word

# Copy the current prompt command to the clipboard
__copy_current_cmd_to_clipboard() {
	~/.config/clipboard/copy.sh "$BUFFER"
}

zle -N __copy_current_cmd_to_clipboard
bindkey '^[y' __copy_current_cmd_to_clipboard

# Open terminal in new window
open_new_terminal() {
	default_term
}

zle -N open_new_terminal
bindkey '^[t' open_new_terminal

# Open terminal file manager
__open_cwd_default_file_manager() {
	default_term_file_manager
}

zle -N __open_cwd_default_file_manager
bindkey '^[m' __open_cwd_default_file_manager

# Show command help
# This calls the current command being typed with the '--help' argument at the end. Not all commands supports it
__show_current_command_help() {
	__expand_alias
	auto-help "${full_cmd[@]}"
	zle reset-prompt
}

zle -N __show_current_command_help
bindkey '^[e' __show_current_command_help

# Open command in $EDITOR
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^e" edit-command-line

# External applications widgets
if [[ "$ALLOW_EXTERNAL_SOFTWARE" == 'y' ]]; then
	# Navi pop-up
	bindkey '^[n' _navi_widget

    # Fzf file widget
	__fzf_custom_file_widget() {
		# The `--scheme=history` option makes the `fzf` prefer select top directories instead of the bottom most
		files=$(fd-by-depth --color=always | fzf --ansi --scheme=history --multi)
		LBUFFER=$(echo "$LBUFFER$files" | tr '\n' ' ')
		zle reset-prompt
	}
	zle -N __fzf_custom_file_widget
	bindkey '^[f' __fzf_custom_file_widget
	bindkey '^[h' atuin-up-search
fi
