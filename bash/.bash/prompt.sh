#!/bin/bash


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
	local color_separator_fg='172'
	local color_line_fg='252'
	local color_text_fg='255'
	local color_comma_fg='255'

	local color_cmd_error_bg='196'
	local color_cmd_error_fg='16'

	local color_command_number_bg='184'
	local color_command_number_fg='16'

	local color_user_fg='220'
	local color_user_sudo_fg='202'

	local color_n_proc_fg='226'
	local color_time_fg='221'

	local color_git_fg='10'
	local color_no_git_fg='214'
	local color_git_detached_fg='214'

	local conda_env_fg='116'

	local color_directory_fg='45'

	local color_prompt_fg='106'
	local color_prompt_sudo_fg='196'

	local color_user_text_fg=$(reset_term_color)$(set_term_foreground_color 255)

	# Error code
	local error_message=''
	if [[ $last_exit_code != 0 ]]; then
		# Left separator
		error_message+="$(set_term_foreground_color $color_cmd_error_bg)󱎕"
		error_message+="$(set_term_background_color $color_cmd_error_bg)"
		error_message+="$(set_term_foreground_color $color_cmd_error_fg)"

		# Content
		error_message+="󰟢 $last_exit_code "

		# Right separator
		error_message+="$(reset_term_color)"
		error_message+="$(set_term_foreground_color $color_cmd_error_bg) "
	fi

	# Command number
	local command_number=""
	command_number+="$(set_term_foreground_color $color_command_number_bg)"
	command_number+="$(set_term_background_color $color_command_number_bg)"
	command_number+="$(set_term_foreground_color $color_command_number_fg)"
	command_number+="\#"
	command_number+="$(reset_term_color)"
	command_number+="$(set_term_foreground_color $color_command_number_bg) "

	# Git branch
	local git_branch=$(git branch --show-current 2>/dev/null || echo 'no git')
	if [ "$git_branch" == '' ]; then  # If is in detached HEAD state
		git_branch="detached"
		color_git_fg=$color_git_detached_fg
	fi
	if [ "$git_branch" == 'no git' ]; then
		color_git_fg=$color_no_git_fg
	fi

	# Conda environment
	local conda_env=$(echo $CONDA_DEFAULT_ENV)
	if [ -n "$conda_env" ]; then
		conda_env="$(set_term_foreground_color $conda_env_fg)󱔎 $conda_env"
		conda_env+="$(set_term_foreground_color $color_comma_fg), "
	fi

	# If has sudo permission
	if sudo -n true 2>/dev/null; then
		color_user_fg=$color_user_sudo_fg
		color_prompt_fg=$color_prompt_sudo_fg
	fi

	# Resets prompt
	PS1=''

	# Before the 
	PS1+="$(reset_term_color)\n"
	PS1+="$(set_term_foreground_color $color_line_fg)╭─"

	# Inside the  and 
	PS1+="$(set_term_foreground_color $color_separator_fg) "
	PS1+="$error_message"
	PS1+="$command_number"
	PS1+="$(set_term_foreground_color $color_user_fg)\u"  # User
	PS1+="$(set_term_foreground_color $color_text_fg) at "
	PS1+="$(set_term_foreground_color $color_time_fg)󰔟 \A"  # Time

	PS1+="$(set_term_foreground_color $color_comma_fg), "
	PS1+="$(set_term_foreground_color $color_git_fg) $git_branch"
	PS1+="$(set_term_foreground_color $color_comma_fg), "
	PS1+="$conda_env"
	PS1+="$(set_term_foreground_color $color_n_proc_fg) \j"  # Number of processes
	PS1+="$(set_term_foreground_color $color_separator_fg)  "

	# After the 
	PS1+="$(set_term_foreground_color $color_text_fg) in "
	PS1+="$(set_term_foreground_color $color_directory_fg) 🖿  \w"  # Directory

	# Line with a vertical bar
	PS1+="$(reset_term_color)\n"
	PS1+="$(set_term_foreground_color $color_line_fg)│\n"


	# Last line (prompt)
	PS1+="$(set_term_foreground_color $color_line_fg)╰─"
	PS1+="$(set_term_foreground_color $color_prompt_fg) 󰅂 "
	PS1+="$color_user_text_fg"

	export PS1
}

PROMPT_COMMAND='refresh_prompt_ps1'


# Continuation prompt
export PS2="   "

# Select mode prompt
export PS3="select: "

# Debug mode prompt
export PS4="$0 :$LINENO "
