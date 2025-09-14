# Does not run this scripts if the user can not install external software
[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ] && return

test -f ~/.local/bin/mise && eval "$(~/.local/bin/mise activate zsh)"
