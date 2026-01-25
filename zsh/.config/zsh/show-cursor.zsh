__show_cursor_escape=$(tput cnorm)

function __show_cursor() {
	echo -ne "$__show_cursor_escape"
}

# Shows (unhide) the cursor before each command prompt
add-zsh-hook precmd __show_cursor
