if [[ "$ALLOW_EXTERNAL_SOFTWARE" == 'y' ]]; then
	source ~/.config/zsh/prompt/init.zsh
else
	source ~/.config/zsh/prompt/fallback.zsh
fi
