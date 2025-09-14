# Does not run this scripts if the user can not install external software
[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ] && return

export PATH="$HOME/.krew/bin:$PATH"
