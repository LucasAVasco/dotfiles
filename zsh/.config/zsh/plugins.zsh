# Does not run this scripts if the user can not install external software
[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ] && return

# Oh my Zsh configuration {{{

export ZSH_CUSTOM=~/.config/zsh/custom_oh_my_zsh

HYPHEN_INSENSITIVE='true'

zstyle ':omz:update' mode reminder # Just remind me to update when it's time
zstyle ':omz:update' frequency 30  # Days

COMPLETION_WAITING_DOTS="%F{white}..."

# Zsh has some functions that adjust the pasted text to work with the command line (e.g. URLs). These functions may mess up with these
# texts. To disable this feature, uncomment the following line
# DISABLE_MAGIC_FUNCTIONS="true"

# I use 'trapd00r/LS_COLORS', so it is unnecessary to set it trough `oh-my-zsh`. Also, the 'lib/theme-and-appearance.zsh' script will add an
# 'ls' alias that conflicts with the one that I configured. The 'getantidote/use-omz' plugin loads the themes into a pre-command, so my 'ls'
# alias will be overridden if I do not disable the default `oh-my-zsh` LS_COLORS
DISABLE_LS_COLORS=true

# }}}

# Antidote configuration {{{

install_dir=~/.antidote
if [[ ! -d "$install_dir" ]]; then
	print -P "\nInstalling %F{blue}%BAntidote%f%b inside %F{cyan}%B${install_dir}%f%b..."
	git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
fi
unset install_dir

# source $ZSH/oh-my-zsh.sh
zstyle ':antidote:bundle' use-friendly-names 'yes'
source ~/.antidote/antidote.zsh
antidote load

# }}}
