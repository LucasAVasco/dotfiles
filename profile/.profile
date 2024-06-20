# To see the default '~/.profile' content, check the '/etc/skel/.profile' file.
#
# The bash does not read this file if the '~/.bash_profile' file exists. '~/.profile' needs to be sourced
# from the '~/.bash_profile' if you want to use it


# Custom paths added to PATH variable
FOLDERS_TO_PATH="$HOME/.bin $HOME/.local/bin $HOME/.local/dotfiles_bin"

for folder in $FOLDERS_TO_PATH; do
	if [ -d "$folder" ]; then
		PATH="$folder:$PATH"
	fi
done


# Custom 'share' folder to hold dot files shared data (e.g. Desktop applications)
export XDG_DATA_DIRS="$XDG_DATA_DIRS:/usr/share/:$HOME/.local/share/:$HOME/.local/dotfiles_share"


# Homebrew on Linux
test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)


# Configurations of Bspwm window manager
if [ "$DESKTOP_SESSION" == "bspwm" ]; then
	# Java applications that use AWT (Abstract Window Toolkit) may not work properly in Bspwm (window becomes white).
	# To disable the reparenting of the toolkit fix this problem
	export _JAVA_AWT_WM_NONREPARENTING=1
fi


# This variable defines if the user can install external software, like extensions or plugins
ALLOW_EXTERNAL_SOFTWARE=y

if ! [[ "$USER" =~ .*_dev$ ]]; then  # Only allow extensions to users that name ends with '_dev'
	ALLOW_EXTERNAL_SOFTWARE=n
fi

ID_RES=($(id))
[ ${ID_RES[0]} == 'uid=0(root)' ] && ALLOW_EXTERNAL_SOFTWARE=n  # Disable extensions to root

for group in $(groups); do  # Disable extensions to users with sudo access
	[ "$group" == 'sudo' ] && ALLOW_EXTERNAL_SOFTWARE=n
done

[ "${USER:0:5}" == 'admin' ] && ALLOW_EXTERNAL_SOFTWARE=n  # Disable extensions to '^admin.*' users

export ALLOW_EXTERNAL_SOFTWARE=$ALLOW_EXTERNAL_SOFTWARE
