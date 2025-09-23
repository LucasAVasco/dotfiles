# Documentation at https://gitlab.freedesktop.org/Per_Bothner/specifications/blob/master/proposals/semantic-prompts.md

# Disable if the terminal does not support the escape sequence
if [[ -z "$WEZTERM_PANE" ]]; then
	return
fi

# Add the prompt start and end escape sequences to the prompt
PROMPT="%{$(print -n "\033]133;N\007")%}""$PROMPT""%{$(print -n "\033]133;B\007")%}"

function __semantic_prompt_start_output() {
	# End of input and start of output
	print -n "\033]133;C\007"
}

function __semantic_prompt_end_command() {
	# End of output (return code is 0)
	print -n "%{\033]133;D;0\007%}"
}

# Register the hooks with Oh My Zsh
autoload -Uz add-zsh-hook
add-zsh-hook preexec __semantic_prompt_start_output
add-zsh-hook precmd __semantic_prompt_end_command
