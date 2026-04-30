#!/bin/bash
#
# Library to manage K3S clusters

source ~/.config/bash/libs/log.sh

# Version of K3S to install. You can use `curl https://update.k3s.io/v1-release/channels/stable` to get the latest version
k3s_version=v1.34.6+k3s1

# Path of the K3S binary
k3s_bin_path=~/.local/share/k3s/bin/k3s



# Get the path of a cluster. Does not check if the cluster exists
#
# $1: cluster name
__k3s_get_cluster_path() {
	local cluster="$1"
	if [[ -z "$cluster" ]]; then
		echo "Cluster name must not be empty" >&2
		exit 1
	fi

	echo -n "$HOME/.local/share/k3s/clusters/$cluster"
}

# Check if a cluster exists
#
# $1: cluster name
__k3s_has_cluster() {
	[[ -d "$(__k3s_get_cluster_path "$1")" ]]
}

# Checks if a cluster exists. Exits if it does not
#
# $1: cluster name
__k3s_validate_cluster_exist() {
	local cluster="$1"
	if ! __k3s_has_cluster "$cluster"; then
		echo "Cluster $cluster does not exist" >&2
		exit 1
	fi
}

# Remove the cluster data
#
# $1: cluster name
k3s_clear_cluster_data() {
	local cluster="$1"
	__k3s_validate_cluster_exist "$cluster"

	local cluster_path=$(__k3s_get_cluster_path "$cluster")
	if [[ -d "$cluster_path/data" ]]; then
		docker run -it --rm -v "$cluster_path":/k3s alpine rm -r /k3s/data/
	fi
}

# Remove a context from the kubeconfig
#
# $1: cluster name
__k3s_remove_cluster_context() {
	local cluster="$1"
	__k3s_validate_cluster_exist "$cluster"

	(
		export NAME="k3s-mgr-$cluster"

		cd ~/.kube

		yq -i 'del(.clusters[] | select(.name == env(NAME)))' config
		yq -i 'del(.users[] | select(.name == env(NAME)))' config
		yq -i 'del(.contexts[] | select(.name == env(NAME)))' config
	)
}

# Add a private registry to the cluster
#
# $1: cluster name
#
# $2: Mirror of the private registry. Example: if you access your private registry in a manifest by the 'private-registry:5000' name, you
# should pass 'private-registry:5000' as this argument
#
# $3: Port of the private registry in the host. Example: if your private registry is running in the 5000 port, you should pass '5000' as
# this argument. The default value is 5000
k3s_cluster_use_private_registry() {
	local cluster=$(__k3s_get_cluster_path "$1")
	__k3s_validate_cluster_exist "$1"

	local register_mirror="$2"
	local registry_port="${3:-5000}"

	# Selects the IP address of the first non-loopback interface. Use the IPV4 (inet) address
	local host_ip=$(ip -json addr show | jq -r '.[] | select(.ifname != "lo") | .addr_info.[] | select(.family == "inet").local')

	# Inserts the private registry in the cluster
	touch "$cluster/registries.yaml"
	yq -i ".mirrors.\"$register_mirror\".endpoint[0] = \"http://$host_ip:$registry_port/\"" "$cluster/registries.yaml"
	yq -i ".mirrors.\"$register_mirror\".\"*\"[0] = \"http://$host_ip:$registry_port/\"" "$cluster/registries.yaml"
	yq -i ".configs.\"$register_mirror\".tls.insecure_skip_verify = true" "$cluster/registries.yaml"
}

# Get the name of the cluster context
#
# $1: cluster name
k3s_get_context_name() {
	local cluster="$1"
	echo -n "k3s-mgr-$cluster"
}

# Add the cluster context to kubeconfig
#
# $1: cluster name
k3s_add_cluster_to_kubeconfig() {
	local cluster="$1"
	__k3s_validate_cluster_exist "$cluster"

	(
		cd ~/.kube

		local k3s_config_file="$(__k3s_get_cluster_path "$cluster")/kubeconfig.yaml"
		export NAME=$(k3s_get_context_name "$cluster")

		# Deletes old configuration
		__k3s_remove_cluster_context "$cluster"

		# Adds new configuration
		k3s_cluster=$(yq '.clusters[0] | .name = env(NAME)' $k3s_config_file) \
		k3s_user=$(yq '.users[0] | .name = env(NAME)' $k3s_config_file) \
		k3s_context="{name: $NAME, context: {cluster: $NAME, user: $NAME }}" \
			yq -i '.clusters += env(k3s_cluster) | .users += env(k3s_user) | .contexts += env(k3s_context)' config

		# Formats the configuration file
		KUBECONFIG=~/.kube/config kubectl config view --flatten | sponge config
	)
}

# Install K3S binary. Use the version defined in the `k3s_version` variable
__k3s_install() {
	mkdir -p $(dirname "$k3s_bin_path")
	curl -Lo "$k3s_bin_path" "https://github.com/k3s-io/k3s/releases/download/$k3s_version/k3s"
	chmod +x "$k3s_bin_path"
}

# Install K3S if it is not installed
__k3s_ensure_installed() {
	# Check if K3S is installed
	if [ ! -f ~/.local/share/k3s/bin/k3s ]; then
		log_info "K3S is not installed. Installing..."
		__k3s_install
	fi

	# Check if the version is correct
	if [[ $("$k3s_bin_path" --version) != *"$k3s_version"* ]]; then
		log_info "K3S version is not correct. Updating..."
		__k3s_install
	fi
}

# Check if K3S is running
__k3s_is_running() {
	am-i-running -f '/k3s server'
}

# Create a new cluster
#
# $1: cluster name
# $2...: registries and host port. Separated by newline
k3s_create_cluster() {
	local cluster="$1"
	shift
	if __k3s_has_cluster "$cluster"; then
		echo "Cluster $cluster already exists" >&2
		exit 1
	fi

	# Creates the cluster folder
	mkdir -p "$HOME/.local/share/k3s/clusters/$cluster"

	# Adds the registries to the cluster
	for registry in "$@"; do
		k3s_cluster_use_private_registry "$cluster" \
		"$(echo "$registry" | sed -n '1p')" \
		"$(echo "$registry" | sed -n '2p')"
	done

	# Starts the cluster
	k3s_start_cluster "$cluster" &

	# Configures the kubeconfig file
	local kubeconfig_path="$(__k3s_get_cluster_path "$cluster")/kubeconfig.yaml"

	# Waits for the kubeconfig file to be created
	while [ ! -f "$kubeconfig_path" ]; do
		sleep 1
	done
	k3s_add_cluster_to_kubeconfig "$cluster"

	# Attach to the k3s process
	wait -n
}

# Start a cluster
#
# $1: cluster name
k3s_start_cluster() {
	# validation
	local cluster="$1"
	__k3s_validate_cluster_exist "$cluster"

	if __k3s_is_running >/dev/null; then
		echo "K3S is already running" >&2
		exit 1
	fi

	__k3s_ensure_installed

	# Changes the kubectl context to the cluster context
	local context_name=$(k3s_get_context_name "$cluster")
	kubectl config set-context "$context_name"
	kubectl config use-context "$context_name"

	# Starts k3s
	local cluster_path=$(__k3s_get_cluster_path "$cluster")
	systemd-run --user -p Delegate=yes --tty \
		"$k3s_bin_path" \
		server --rootless --snapshotter=fuse-overlayfs --prefer-bundled-bin \
		-d "$cluster_path/data" --private-registry "$cluster_path/registries.yaml" \
		--write-kubeconfig "$cluster_path/kubeconfig.yaml"
}

# Stops K3S if it is running. Does not delete the cluster data
k3s_stop() {
	if __k3s_is_running; then
		pkill -f '/k3s server'
	fi
}

# Stop K3S and delete the cluster
#
# $1: cluster name
k3s_delete_cluster() {
	local cluster="$1"
	__k3s_validate_cluster_exist "$cluster"

	k3s_stop
	__k3s_remove_cluster_context "$cluster"
	k3s_clear_cluster_data "$cluster"

	local cluster_path=$(__k3s_get_cluster_path "$cluster")
	trash "$cluster_path"
}
