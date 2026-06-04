# To see the default '~/.profile' content, check the '/etc/skel/.profile' file.
#
# The bash does not read this file if the '~/.bash_profile' file exists. '~/.profile' needs to be sourced
# from the '~/.bash_profile' if you want to use it


# Indicate that the profile was already sourced
export PROFILE_ALREADY_SOURCED=y


# Custom paths added to PATH variable
export PATH="$PATH:$HOME/.local/bin:$HOME/.local/dotfiles_bin"


# Custom 'share' folder to hold dot files shared data (e.g. Desktop applications)
export XDG_DATA_DIRS="$XDG_DATA_DIRS:/usr/share/:$HOME/.local/share/:$HOME/.local/dotfiles_share"


# Configurations of Bspwm window manager
if [ "$DESKTOP_SESSION" = "bspwm" ]; then
	# Java applications that use AWT (Abstract Window Toolkit) may not work properly in Bspwm (window becomes white).
	# To disable the reparenting of the toolkit fix this problem
	export _JAVA_AWT_WM_NONREPARENTING=1
fi

# Ensures some default environment variables exist
if [ -z "$XDG_RUNTIME_DIR" ]; then
	export XDG_RUNTIME_DIR="/var/run/user/$(id -u)"
fi

# Apps environment variables
export PODMAN_COMPOSE_PROVIDER=podman-compose
export BUILDKIT_PROGRESS=plain
export ROOTLESSKIT_STATE_DIR="${XDG_RUNTIME_DIR}/dockerd-rootless"
export LIBVIRT_DEFAULT_URI="qemu:///session?socket=/run/user/$(id -u)/libvirt/libvirt-sock"


# Defines UTF8 characters that LESS should print the icons instead of its numeric value
# Source available at https://github.com/sharkdp/bat/issues/2578
export LESSUTFCHARDEF=E000-F8FF:p,F0000-FFFFD:p,100000-10FFFD:p


# Save packages in other folders
export TEXMFHOME=$HOME/.texmf # TeX packages
export GOPATH="$HOME/.local/share/go" # Go packages


# `d-log` configuration
export D_LOG_GROUP='' # Configure Bash and Zsh to allow auto-complete 'D_LOG_GROUP' environment variable


# This variable defines if the user can install external software, like extensions or plugins
ALLOW_EXTERNAL_SOFTWARE=y

if ! [[ "$USER" =~ .*_dev$ ]]; then  # Only allow extensions to users that name ends with '_dev'
	ALLOW_EXTERNAL_SOFTWARE=n
fi

ID_RES=($(id))
[ "${ID_RES[0]}" = 'uid=0(root)' ] && ALLOW_EXTERNAL_SOFTWARE=n  # Disable extensions to root

for group in $(groups); do  # Disable extensions to users with sudo access
	[ "$group" = 'sudo' ] && ALLOW_EXTERNAL_SOFTWARE=n
done

[ "${USER:0:5}" = 'admin' ] && ALLOW_EXTERNAL_SOFTWARE=n  # Disable extensions to '^admin.*' users

export ALLOW_EXTERNAL_SOFTWARE=$ALLOW_EXTERNAL_SOFTWARE


# Variable that indicates if the shell is running inside a container
if [ -z "$RUNNING_INSIDE_CONTAINER" ]; then
	if [ -f /.dockerenv -o -f /run/.containerenv ]; then
		export RUNNING_INSIDE_CONTAINER=y
	else
		export RUNNING_INSIDE_CONTAINER=n
	fi
fi


# Apps configuration
export FZF_DEFAULT_OPTS_FILE=~/.fzfrc

if [ "$ALLOW_EXTERNAL_SOFTWARE" = y ]; then
	# Mason binaries
	export PATH="$PATH:$HOME/.local/share/nvim/mason/bin/"

	# Homebrew on Linux
	test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
	test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

	# Nix configuration
	export PATH="$PATH:$HOME/.nix-profile/bin"
	export XDG_DATA_DIRS="$XDG_DATA_DIRS:$HOME/.nix-profile/share"

	# Default shell. Some terminal emulators use this environment variable to select its shell
	export SHELL=/bin/zsh

	# If the user's default shell is Bash, enable ASDF. This allows applications that are not launched directly by an interactive bash
	# session to use some software installed by ASDF. Requires the user's default shell to be `bash`
	if [ "$0" = 'bash' -o "$0" = '-bash' ]; then
		export PATH="$HOME/.asdf/shims:$PATH"
		if [ -d ~/.local/share/mise/ ]; then
			eval "$(~/.local/bin/mise activate --shims bash)"
		else
			export PATH="$HOME/.local/share/mise/shims:$PATH"
		fi
	fi

	# Lua environment variables
	lua -v >/dev/null 2>&1 && {
		lua_version=$(lua -e 'print(_VERSION:match("%d+%.%d+"))')
		export LUA_PATH="$HOME/.luarocks/share/lua/$lua_version/?.lua;;"
		export LUA_CPATH="$HOME/.luarocks/lib/lua/$lua_version/?.so;;"
		export PATH="$PATH:$HOME/.luarocks/bin"
	}
fi

# VCPKG
export VCPKG_ROOT=~/.cache/vcpkg-install

if [ "$ALLOW_EXTERNAL_SOFTWARE" = y ]; then
	# CMake defaults
	export CMAKE_EXPORT_COMPILE_COMMANDS=1

	# Overrides some binaries
	export PATH="$HOME/.local/dotfiles_bin_override:$PATH"

	# Fallback installers (must be the last element of the path)
	export PATH="$PATH:$HOME/.local/dotfiles_bin_fallback/bin:$HOME/.local/dotfiles_bin_fallback/build/installers"
fi
