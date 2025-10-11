# Configuration applied if running docker inside a container
if [[ -f /.dockerenv ]]; then
	source ~/.profile # Docker does not source .profile by default
	export RUNNING_INSIDE_CONTAINER=y
	export ALLOW_EXTERNAL_SOFTWARE=y

	# Allows more colors
	export TERM=xterm-256color
else
	export RUNNING_INSIDE_CONTAINER=n
fi

# ZSH debug mode
# DEBUG_ZSH_STARTUP=1
[[ "$DEBUG_ZSH_STARTUP" == 1 ]] && zmodload zsh/zprof

# Set default editor
export EDITOR='nvim'
export VISUAL='nvim'
export RLWRAP_EDITOR="nvim '+call cursor(%L,%C)'"

zstyle ":completion:*:commands" rehash 1

# History configuration
HISTFILE=~/.zsh_history
HIST_STAMPS="%y/%m/%d %T  "
HISTSIZE=5000
SAVEHIST=2000
setopt appendhistory
setopt HIST_IGNORE_SPACE
unsetopt correct  # Disable auto correct

# Delay (in hundredths of seconds) that differentiates between a ESC key or a key with special meaning (alt, function key, etc.)
# Example: KEYTIMEOUT=1 sets a delay of 10 milliseconds
KEYTIMEOUT=1

# source other scripts
source ~/.config/zsh/plugins.zsh
source ~/.config/zsh/apps/asdf.zsh
source ~/.config/zsh/apps/mise.zsh
source ~/.config/zsh/apps/k8s.zsh
source ~/.config/zsh/apps/file-manager.sh
source ~/.config/zsh/apps/other.zsh
source ~/.config/zsh/commands.zsh
source ~/.config/zsh/completions.zsh
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/prompt.zsh
source ~/.config/zsh/semantic-prompts.zsh # Must be sourced after setting the prompt and Oh My Zsh configuration
source ~/.config/zsh/keybinds.zsh # Must be sourced after Oh My Zsh configuration

# Vi prompt shape {{{

if [[ "$ALLOW_EXTERNAL_SOFTWARE" == 'y' ]]; then
	# Updates the cursor after enter or exit insert mode (only for VI key binds)
	# This function is terminal specific, so you may need to adjust it to work in your terminal emulator.
	# Tested terminal emulators: Alacritty, Alacritty with Tmux, Kitty, Kitty with Tmux, Wezterm
	# '\e[1 q': Code to block (blinking)
	# '\e[2 q': Code to block (without blinking)
	# '\e[3 q': Code to underscore (blinking)
	# '\e[4 q': Code to underscore (without blinking)
	# '\e[5 q': Code to vertical bar (blinking)
	# '\e[6 q': Code to vertical bar (without blinking)
	_update_vi_cursor_shape() {
		case $KEYMAP in
			main)  # If going to insert mode
				echo -ne '\e[6 q';;

			vicmd)  # If going to normal mode
				echo -ne '\e[2 q';;
		esac
	}

	autoload -Uz add-zle-hook-widget
	add-zle-hook-widget zle-line-init _update_vi_cursor_shape
	add-zle-hook-widget zle-keymap-select _update_vi_cursor_shape
	add-zle-hook-widget zle-line-finish _update_vi_cursor_shape
fi

# }}}

# ZSH debug mode
if [[ "$DEBUG_ZSH_STARTUP" == 1 ]]; then
	zprof

	if [[ -z "$DISABLE_ZSH_STARTUP_TIME" ]]; then
		export DISABLE_ZSH_STARTUP_TIME=y
		time zsh -i -c exit
	fi
fi
