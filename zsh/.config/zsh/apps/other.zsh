# Load external software to work with zsh

# Does not run this scripts if the user can not install external software
[ "$ALLOW_EXTERNAL_SOFTWARE" != 'y' ] && return

# Direnv
eval "$(direnv hook zsh)"

# Fzf (the `--zsh` flag may not be implemented in some OS, ignore the error message)
source <(fzf --zsh 2> /dev/null)

# Navi
if [[ -f ~/.cargo/bin/navi ]]; then
	PATH="$PATH:$HOME/.cargo/bin"
fi
eval "$(navi widget zsh)"

# Atuin
if [[ ! -f ~/.cargo/bin/atuin && ! -f ~/.atuin/bin/atuin ]]; then
	mise use rust
	cargo install atuin
fi
eval "$(atuin init zsh --disable-ctrl-r --disable-up-arrow)"
bindkey '^[h' atuin-up-search

# Zoxide
eval "$(zoxide init zsh)"
alias cd='z'

# Eza
alias exa='/usr/bin/exa --smart-group --group --icons=always --color=always --git --hyperlink'
alias eza='/usr/bin/eza --smart-group --group --icons=always --color=always --git --hyperlink'
[[ -f /usr/bin/exa ]] && alias ls='exa'
[[ -f /usr/bin/eza ]] && alias ls='eza'

# Bat
[[ -f /usr/bin/bat ]] && alias cat='bat'
[[ -f /usr/bin/batcat ]] && alias cat='batcat'

# Nix
alias nix-zsh='nix-shell --run zsh'

# Delta
alias delta-side='DELTA_FEATURES="+side-by-side" delta'

# Ripgrep
alias rg='rg --color=always'

# Kubernetes related
alias kind-set-current-cluster='KIND_CURRENT_CLUSTER=$(kind get clusters | fzf --header="Kind cluster:")'
