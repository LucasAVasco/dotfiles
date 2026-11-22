if [[ "$PROFILE_ALREADY_SOURCED" != y && -f ~/.profile ]]; then
	source ~/.profile
fi

test -f ~/.bashrc && source ~/.bashrc
