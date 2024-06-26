# Bash configuration file
#
# This file holds configurations to all users including root and users with sudo access. The configuration specific to non-root
# and users without sudo access need to be placed in the '~/.bash/user_config.sh' file


# Only executes this configuration script in interactive mode
[[ $- != *i* ]] && return


# #region History configuration

HISTSIZE=5000      # Number of commands to save in the history
HISTFILESIZE=20000 # Max number of lines of the history file (recommended to be greater than HISTSIZE)

HISTTIMEFORMAT='%y/%m/%d %T  '
shopt -s histappend

# Sets how the commands are saved in the history list. 'ignoreboth' is a alias to 'ignorespace' (does not saves lines that strts with a space
# and 'ignoredups' (does not saves duplicated sequential lines)
HISTCONTROL=ignoreboth

# #endregion


# Updates $LINES and $COLUMNS after each command
shopt -s checkwinsize


# Set default editor
export EDITOR='nvim'
export VISUAL=nvim


# Bash aliases
source ~/.bash/aliases.sh


# User configurations
source ~/.bash/non_root_config.sh


# Source Prompt
if [ "$TERM" == "linux" -o "$TERM" == "tmux" ]; then
	source ~/.bash/ascii_prompt.sh
else
	source ~/.bash/prompt.sh
fi
