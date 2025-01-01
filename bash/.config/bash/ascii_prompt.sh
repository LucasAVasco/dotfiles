#!/bin/bash
#
# Basic prompot that only use ascii characters. Does not have integration with git, Conda, etc.
#
# Is a simple solution to simple prompts like the default Linux 'tty' prompt (without GUI).


set_term_foreground_color() {
	echo -ne "\[\033[38;5;${1}m\]"
}


set_term_background_color() {
	echo -ne "\[\033[48;5;${1}m\]"
}


reset_term_color() {
	echo -ne "\[\033[0m\]"
}


# Update prompt
refresh_prompt_ps1() {
	local last_exit_code="$?"  # Exit code of last command (need to be first)

	# Colors
	local color_separator_fg='1'
	local color_line_fg='15'
	local color_text_fg='15'
	local color_comma_fg='15'

	local color_cmd_error_bg='9'
	local color_cmd_error_fg='0'

	local color_command_number_bg='0'
	local color_command_number_fg='11'

	local color_user_fg='10'
	local color_user_sudo_fg='9'

	local color_n_proc_fg='11'
	local color_time_fg='3'

	local color_directory_fg='14'

	local color_prompt_fg='10'
	local color_prompt_sudo_fg='9'

	local color_user_text_fg=$(reset_term_color)$(set_term_foreground_color 15)

	# Error code
	local error_message=''
	if [[ $last_exit_code != 0 ]]; then
		# Content
		error_message+="$(set_term_foreground_color $color_cmd_error_fg)"
		error_message+="$(set_term_background_color $color_cmd_error_bg)"
		error_message+="E: $last_exit_code "
		error_message+="$(reset_term_color) "
	fi

	# Command number
	local command_number=""
	command_number+="$(set_term_background_color $color_command_number_bg)"
	command_number+="$(set_term_foreground_color $color_command_number_fg)"
	command_number+="C: \#"
	command_number+="$(reset_term_color) "

	# If has sudo permission
	if sudo -n true 2>/dev/null; then
		color_user_fg=$color_user_sudo_fg
		color_prompt_fg=$color_prompt_sudo_fg
	fi

	# Resets prompt
	PS1=''

	# Before the (
	PS1+="$(reset_term_color)\n "

	# Inside the ( and )
	PS1+="$(set_term_foreground_color $color_separator_fg)( "
	PS1+="$error_message"
	PS1+="$command_number"
	PS1+="$(set_term_foreground_color $color_user_fg)U: \u"  # User
	PS1+="$(set_term_foreground_color $color_text_fg) at "
	PS1+="$(set_term_foreground_color $color_time_fg)T: \A"  # Time

	PS1+="$(set_term_foreground_color $color_comma_fg), "
	PS1+="$(set_term_foreground_color $color_n_proc_fg)P: \j"  # Number of processes
	PS1+="$(set_term_foreground_color $color_separator_fg) ) "

	# After the )
	PS1+="$(set_term_foreground_color $color_text_fg) in "
	PS1+="$(set_term_foreground_color $color_directory_fg)  \w"  # Directory

	# Empty line
	PS1+="$(reset_term_color)\n\n"

	# Last line (prompt)
	PS1+="$(set_term_foreground_color $color_line_fg)-"
	PS1+="$(set_term_foreground_color $color_prompt_fg) $ "
	PS1+="$color_user_text_fg"

	export PS1
}

PROMPT_COMMAND='refresh_prompt_ps1'


# Continuation prompt
export PS2=">   "

# Select mode prompt
export PS3="select: "

# Debug mode prompt
export PS4="$0 L:$LINENO) "
