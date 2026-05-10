#!/bin/bash
#
# Tool to manage K3S clusters. Runs K3S in rootless mode in the host machine (does not run in a container or virtual machine)

set -e

source ~/.local/lib/dotfiles/bash/help.sh

help_handle y "$@" <<EOF
	Tool to manage K3S clusters. Runs K3S in rootless mode in the host machine (does not run in a container or virtual machine). The
	commands are based in the 'k3d' commands, but compatibility is not guaranteed

	USAGE
		k3s-mgr registry create <name> [host-port]
			Create a registry and expose it in the given port (defaults to 5000). Fail if the registry already exists.

		k3s-mgr registry start <name>
			Start a already created registry

		k3s-mgr registry stop <name>
			Stop a running registry. Does not delete the registry

		k3s-mgr registry delete <name>
			Stop and delete a registry

		k3s-mgr cluster create <name> [ <mirror> [port] ]...
			Create a new cluster. Fail if the cluster already exists. You can provide one or more private registries to be used by the
			cluster after the cluster name. Each registry must be provided in the same format as the 'k3s-mgr cluster use-private-registry'
			command

		k3s-mgr cluster start <name>
			Start a already created cluster

		k3s-mgr cluster stop <name>
			Stop K3S and delete the cluster

		k3s-mgr cluster delete <name>
			Stop K3S and delete the cluster

		k3s-mgr cluster use-private-registry <mirror> [port]
			Configure a private registry in the cluster, so K3S can pull images from it. You must provide its mirror name (how it will be
			referenced in the manifests). The port of the registry in the host is optional and defaults to 5000. Example: if you access your
			private registry in a manifest by the 'private-registry:5000' name and it is exposed in the 3456 port of your host machine, you
			should pass 'private-registry:5000' as the mirror argument and '3456' as the port argument

		k3s-mgr cluster remove-private-registry <mirror>
			Remove a private registry from the cluster

		k3s-mgr kubeconfig merge <cluster>
			Merge the kubeconfig of the given cluster into the current kubeconfig

		k3s-mgr redirect-ingress
			Rootless K3S redirects ingress traffic to ports 10080 (HTTP) and 10443 (HTTPs). This command redirect this traffic to ports 8080
			(HTTP) and 8443 (HTTPs)
EOF

# All operations are relative to the current directory
current_dir=$(dirname `realpath "${BASH_SOURCE[0]}"`)
cd "$current_dir"

# Load libraries
source ./libs/registry.sh
source ./libs/k3s.sh

# Parse arguments
main_command="$1"
shift

if [[ -n "$1" ]]; then
	sub_command="$1"
	shift
fi

# Executes the main command
case "$main_command" in
	registry)
		case "$sub_command" in
			create)
				registry_create "$1" "$2"
				;;

			start)
				registry_start "$1"
				;;

			stop)
				registry_stop "$1"
				;;

			delete)
				registry_delete "$1"
				;;

			*)
				echo "Unknown registry sub-command: $sub_command" >&2
				exit 1
				;;
		esac
		;;


	cluster)
		case "$sub_command" in
			create)
				cluster="$1"
				shift

				# List of private registries to add to the cluster
				private_registries=()
				while [[ $# -gt 0 ]]; do
					if [[ "$1" == "--use-private-registry" ]]; then
						shift
						registry=$(printf "%s\n%s" "$1" "$2")
						private_registries+=("$registry")

						shift $(($# > 1 ? 2 : 1))
					else
						echo "Unknown argument: $1" >&2
					fi
				done

				k3s_create_cluster "$cluster" "${private_registries[@]}"
				;;

			start)
				k3s_start_cluster "$1"
				;;

			stop)
				k3s_stop
				;;

			delete)
				k3s_delete_cluster "$1"
				;;

			clear)
				k3s_clear_cluster_data "$1"
				;;

			use-private-registry)
				k3s_cluster_use_private_registry "$1" "$2" "$3"
				;;

			*)
				echo "Unknown cluster sub-command: $sub_command" >&2
				exit 1
				;;
		esac
		;;

	kubeconfig)
		case "$sub_command" in
			merge)
				k3s_add_cluster_to_kubeconfig "$1"
				;;

			*)
				echo "Unknown kubeconfig sub-command: $sub_command" >&2
				exit 1
				;;
		esac
		;;

	redirect-ingress)
		# INFO(LucasAVasco): Rootless K3S redirects system ports (1-1024) to a high port by adding an offset of 10000 to the port number.
		# This means that the ingress port are 10080 and 10443. Add a command to redirect ingress related ports (80 and 443) to its
		# alternatives ports (8080 and 8443)

		socat TCP-LISTEN:8080,fork TCP:localhost:10080 &
		socat TCP-LISTEN:8443,fork TCP:localhost:10443 &
		wait -n
		;;

	*)
		echo "Unknown main command: $main_command" >&2
		exit 1
		;;
esac
