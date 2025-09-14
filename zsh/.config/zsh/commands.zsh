secrets-man () {
	case "$1" in
		enable)
			export SECRETES_MAN_ENABLED=1
			~/.local/dotfiles_bin/secrets-man enable
			echo 'Secrets manager enabled'
		;;

		disable)
			export SECRETES_MAN_ENABLED=1
			echo 'Secrets manager disabled'
		;;

		*)
			~/.local/dotfiles_bin/secrets-man "$@"
		;;
	esac
}
