current_dir=$(dirname `realpath "${(%):-%x}"`)

setopt prompt_subst

# Ensures the prompt is built
if [[ ! -f "$current_dir/build/left" ]]; then
	"$current_dir/build.sh"
fi

# Used terminal capabilities
zmodload zsh/terminfo

__terminfo_down_code="$terminfo[cud1]"  # Code to move terminal down
__terminfo_up_code="$terminfo[cuu1]"    # Code to move terminal up
__terminfo_clear_line="$terminfo[el]"   # Code to clear the line (remove contents but not remove the line)
__terminfo_delete_line="$terminfo[dl1]" # Code to delete the line

# Prompt building. Only if the binary does not exists
build_dir="$current_dir/build"
[[ -d "$build_dir" ]] || ~/.config/zsh/prompt/build.sh

# VARIABLES {{{

declare -i __my_zsh_theme_cmd_num=1            # Index of the current command
declare -i __my_zsh_theme_show_cmd_separator=0 # Show the last command error in the next prompt (1 to show, !1 to not show)
declare -i __my_zsh_theme_last_cmd_error=0     # Error code returned by the last command
declare -i __my_zsh_theme_cmd_lines_number=0   # Number of lines of the typed command
declare -i __my_zsh_theme_move_prompt_down=-1  # Move the prompt down instead of creating a new one (1 to move, !1 to not move)

# }}}

# HOOKS {{{

autoload -U add-zsh-hook
autoload -U add-zle-hook-widget

add-zsh-hook preexec __my_zsh_theme_preexec
__my_zsh_theme_preexec() {
	__my_zsh_theme_cmd_time=$EPOCHREALTIME

	__my_zsh_theme_cmd_num+=1
	__my_zsh_theme_show_cmd_separator=2 # Show the last command error in the next prompt
	__my_zsh_theme_move_prompt_down=-1 # Should not move the prompt down before a new command

	"$current_dir/build/override_last_prompt" --cmd-lines-num "$__my_zsh_theme_cmd_lines_number" \
		--terminfo-mv-cursor-up "$__terminfo_up_code" --terminfo-mv-cursor-down "$__terminfo_down_code" \
		--terminfo-clear-line "$__terminfo_clear_line" --terminfo-delete-line "$__terminfo_delete_line"
}

add-zsh-hook precmd __my_zsh_theme_precmd
__my_zsh_theme_precmd() {
	__my_zsh_theme_last_cmd_error=$?

	if [[ "$__my_zsh_theme_move_prompt_down" -le 0 ]]; then
		# Makes if equal to 1 if not after a new command (user presses enter without a command)
		__my_zsh_theme_move_prompt_down+=1
	fi

	if [[ "$__my_zsh_theme_show_cmd_separator" > 0 ]]; then
		# Makes it equal to 1 only after a new command
		__my_zsh_theme_show_cmd_separator+=-1
	fi

	__my_zsh_theme_cmd_lines_number=0 # Resets the number of lines of the typed command

	# Add a padding in the bottom, so the prompt will not touch the bottom margin. This is made by moving the cursor down (move 1/4 of the
	# screen height), and move up to the original position
	local spacer=''  # Text that moves the cursor
	for ((i = 0; i < $LINES/4; i++)); do
		spacer="$__terminfo_down_code$spacer$__terminfo_up_code"
	done

	echo -n "%{$spacer%}"  # Apply the centralization. Need to be inside a escape otherwise the tab-completion will move the cursor up
}

add-zle-hook-widget zle-line-finish __my_zsh_theme_count_lines
__my_zsh_theme_count_lines() {
	# Count the number of lines of the typed command
	__my_zsh_theme_cmd_lines_number=$(($__my_zsh_theme_cmd_lines_number+$BUFFERLINES))
}

# }}}

PROMPT='$('"$current_dir/build/left"' --columns $COLUMNS --cmd-num $__my_zsh_theme_cmd_num --last-error $__my_zsh_theme_last_cmd_error \
	--cmd-start-time "$__my_zsh_theme_cmd_time" --time-now "$EPOCHREALTIME" --show-cmd-separator $__my_zsh_theme_show_cmd_separator \
	--mv-prompt-down $__my_zsh_theme_move_prompt_down \
	--terminfo-mv-cursor-up "$__terminfo_up_code" --terminfo-mv-cursor-down "$__terminfo_down_code" \
	--terminfo-clear-line "$__terminfo_clear_line")'

# TODO: Show the prompt before ZSH loads
