# Does not run this scripts if the user can not install external software
[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ] && return

# ASDF and its completions (only if not already sourced from the '~/.profile' file)
asdf_shims=""
if [[ *":$PATH:"* != *":$HOME/.asdf/shims:"* ]]; then
	export PATH="$HOME/.asdf/shims:$PATH"
fi

fpath=($HOME/.asdf/completions $fpath)
