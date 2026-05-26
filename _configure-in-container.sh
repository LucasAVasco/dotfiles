#!/bin/bash
#
# Configure the dotfiles in a container
#
# Environment variables:
#   MAIN_USER: Main user name

set -euo pipefail

# Copy repository from a folder to another one
#
# $1: source repository folder
# $2: destination repository folder
copy_repository() {
	local src_dir="$(realpath -m "$1")"
	local dest_dir="$(realpath -m "$2")"

	if [[ ! -d "$src_dir/.git" ]]; then
		cp -r "$src_dir" "$dest_dir"
		return
	fi

	(
		cd "$src_dir"
		rsync -av --files-from=<(git ls-files --cached --others --exclude-standard) . "$dest_dir"
		cp -r .git "$dest_dir"
	)
}

# Copy repository from a folder to another one or clone it if it does not exist
#
# $1: source repository folder
# $2: destination repository folder
copy_repository_or_clone() {
	local src_dir="$(realpath -m "$1")"
	local repo="$2"
	local dest_dir="$(realpath -m "$3")"

	if [[ ! -d "$src_dir/" ]]; then
		git clone "$repo" "$dest_dir"
		return
	fi

	copy_repository "$src_dir" "$dest_dir"
}

main_user="$MAIN_USER"

# Root and admin password
read -s -p "Root password: " root_password
echo
read -s -p "Root password (confirm): " root_password_confirm
echo
if [[ "$root_password" != "$root_password_confirm" ]]; then
	echo "Passwords do not match" >&2
	exit 1
fi
unset root_password_confirm

# Update system
pacman -Syu --noconfirm

# Install reflector and update registry
pacman -Syu --noconfirm reflector
reflector @/etc/xdg/reflector/reflector.conf

# Install dependencies to run this script
pacman -S --noconfirm git sudo rsync make

# Create a script that outputs the password to stdout, but requires the password to be available as the ROOT_PASSWORD environment variable.
# Can be used with `sudo --ask-pass`
ask_pass_script='/tmp/ask-pass.sh'
echo -en '#!/bin/bash\ncat <<<"${ROOT_PASSWORD}"' > "$ask_pass_script"
chmod +x "$ask_pass_script"

# Copy archlinux-scripts
mkdir /arch_scripts
copy_repository_or_clone /host/Repositories/archlinux-scripts/ https://github.com/LucasAVasco/archlinux-scripts /arch_scripts
cd /arch_scripts

# Configure archlinux-scripts
export ARCHLINUX_SCRIPTS_GUI_SUPPORTED=n
cat > conf.sh <<EOF
export ARCHLINUX_SCRIPTS_MAIN_USER='$main_user'
SCRIPTS_TO_INSTALL=(
	./scripts/basic-apps/compression.sh
	./scripts/basic-apps/image.sh
	./scripts/basic-apps/security.sh
	./scripts/basic-apps/sync.sh
	./scripts/desktop/commom.sh
	./scripts/dev/base.sh
	./scripts/dotfiles/*.sh
	./scripts/essential/security.sh
)
ARCHLINUX_SCRIPTS_ROOTLESS_DOCKER=y
EOF

# Install archiso scripts (base setup required by the other scripts)
cd archiso
./create-users.sh
passwd --stdin admin <<< "$root_password"
passwd --stdin root <<< "$root_password"
SUDO_ASKPASS="$ask_pass_script" ROOT_PASSWORD="$root_password" \
	sudo --preserve-env='SUDO_ASKPASS,ROOT_PASSWORD' -u admin \
	./install-yay.sh --pacman-args '--noconfirm' --sudo-args '--askpass'
cd ..

# Install other scripts
ARCHLINUX_SCRIPTS_ASK_TO_INSTALL=n make install

# Save a copy of archlinux-scripts in the user ~/Repositories/ folder
dev_user="${main_user}_dev"
mkdir -p "/home/$dev_user/Repositories/"
copy_repository /arch_scripts "/home/$dev_user/Repositories/archlinux-scripts"

# Copy dotfiles
mkdir -p "/home/$dev_user/.local/"
copy_repository_or_clone /host/.local/dotfiles/ https://github.com/LucasAVasco/dotfiles "/home/$dev_user/.local/dotfiles"

# Copy neovim repositories
mkdir -p "/home/$dev_user/Repositories/neovim_repos/"
for repo in $(ls /host/Repositories/neovim_repos/); do
	copy_repository "/host/Repositories/neovim_repos/$repo" "/home/$dev_user/Repositories/neovim_repos/$repo"
done

# Change ownership
chown -R "$dev_user:$dev_user" "/home/$dev_user"

# Enable the dotfiles
cd "/home/$dev_user/.local/dotfiles"
rm "/home/$dev_user/.bashrc" "/home/$dev_user/.bash_profile"
sudo -u "$dev_user" bash -c "source ~/.local/dotfiles/profile/.profile && make enable"

# Setup D-Bus
mkdir -p /var/lib/dbus /run/dbus
dbus-uuidgen --ensure=/etc/machine-id
ln -sf /etc/machine-id /var/lib/dbus/machine-id
dbus-daemon --system --fork

# Setup notification-bridge

# Download the notification-bridge
#
# Return the path to the notification-bridge executable
download_notification_bridge() {
	# Installation path
	local install_dir="/container-notification-bridge-bin/"
	mkdir -p "$install_dir"
	local executable="$install_dir/container-notification-bridge"

	# Download
	local repository='https://github.com/LucasAVasco/container-notification-bridge'
	local version='v1.0.2'
	curl -L "$repository/releases/download/$version/container-notification-bridge-$(uname -m)" \
		--output "$executable"

	# Permissions
	chmod u+x,g+x,o+x "$executable"

	# Return the path
	echo -n "$executable"
}

# Get the path to the notification-bridge executable
notification_bridge_path=$(download_notification_bridge)

# Forwards the socket to another one with more permissive permissions (all users can access it)
pacman -S --noconfirm socat
mkdir -p /container-notification-bridge
socat UNIX-LISTEN:/container-notification-bridge/socket,mode=666,fork UNIX-CONNECT:/container-notification-bridge-root/socket &
export CONTAINER_NOTIFICATION_BRIDGE_SOCKET="/container-notification-bridge/socket"

# Change to development user
unset root_password
startup_command=$(cat <<EOF
	source ~/.profile
	export \$(dbus-launch)
	"$notification_bridge_path" container &
	fallback-installer-man add mise
	zsh
EOF
)

cd "/home/$dev_user"
sudo -u "$dev_user" \
	--preserve-env=CONTAINER_NOTIFICATION_BRIDGE_SOCKET \
	bash -c "$startup_command"
