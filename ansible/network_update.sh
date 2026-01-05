#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

# v0.1 02/25/2022 Maintainer script
# v0.2 04/22/2024 Add OpenBSD support
# v0.3 09/22/2025 Major change to the logicdddd

set -e # uo pipefail # Exit on error, exit on unset variables, fail if any command in a pipe fails.
#IFS=$'\n\t'        # Preserve newlines and tabs in word splitting.

# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="/mnt/storage1/workspace/lab-franklin/bin"
if [ -d "${SCRIPT_DIR}" ]; then source "${SCRIPT_DIR}/common.sh"; else log_error "Unable to find your script directory"; fi

export DEBIAN_FRONTEND="noninteractive"

# --- Helper Functions for Logging ---
log_warn() { printf >&2 "${YELLOW}WARN:${NC} %s\n" "$1"; }
log_success() { printf "${LGREEN}==>${NC} \e[1m%s\e[0m\n" "$1"; } # Using printf for Bold

log_error() {
  printf "${LRED}ERROR: %s${NC}\n" "$1" >&2
  exit 1
}

# --- Some config Variables ----------------------------------------
CONTAINER=false
ETC_DIR="${ANSIBLE_HOME}"

# Check if we are inside a container
function check_container() {
	log_header "Check Container Status ------------------------------------------" && echo -e "\n"
	if [ -f /.dockerenv ]; then
		log_warn "Containerized build environment..." && echo -e "\n"
		CONTAINER=true
	else
		log_info "NOT a containerized build environment" && echo -e "\n"
	fi
}

function check_installed() {
	if command -v "${1}" &>/dev/null; then
		log_info "Found command: ${1}" && echo -e "\n"
		return 0
	else
		log_warn "${1} was not found" && echo -e "\n"
		return 1
	fi
}

function configure_head_node() {
	log_header "\nConfigure Head Node: head2" && echo -e "\n"
	# python3 -m pip install ansible-dev-tools --break-system-packages
}

function configure_nvidia() {
	log_header "\nConfigure GPU Nodes" && echo -e "\n"

	NVIDIA_NODES=$(ansible -i "${ANSIBLE_HOME}/hosts" -b --list-hosts nvidia_nodes | grep BITSMASHER.NET)
	#readarray -t y <<<"$NVIDIA_NODES"
	readarray -t MY_ARR <<<"$NVIDIA_NODES"
	declare -p MY_ARR

	for line in "${MY_ARR[@]}"; do
		line=$(echo $line | xargs)
		log_info "Found GPU: $line"

		# 1. Install NVIDIA's JetPack OS. It's recommended to follow the official NVIDIA documentation for this step.

		# 2. Install NVIDIA Container Toolkit: Install the nvidia-container-toolkit package.
		clush -v -w "${line}" sudo apt-get -y install nvidia-container-toolkit

		# 3. Install K3s: Use the official K3s installation script for aarch64 systems.
		clush -v -w "${line}" "curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644"

		# 4. Configure Containerd: K3s uses containerd as its runtime by default.
		# To enable GPU support, edit the containerd configuration file to include the NVIDIA runtime.
		clush -v -w "${line}" sudo cp /var/lib/rancher/k3s/agent/etc/containerd/config.toml /var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl
		# default_runtime_name = "nvidia"
		# 5. Verify K3s Installation: Check that the K3s node is ready and the NVIDIA runtime is configured correctly.
		#sudo k3s kubectl get nodes
		#sudo grep nvidia /var/lib/rancher/k3s/agent/etc/containerd/config.toml
	done

}

# this function needs to attempt an apt-get update && upgrade
# it also needs to account for failures in apt-get
function apt-get-target() {

	# for the 32 bit armhf hosts
	# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6ED0E7B82643E131 78DBA3BC47EF2265 F8D2585B8783D481

	CLUSH_GROUPS=(compute gpu)

	for i in "${CLUSH_GROUPS[@]}"; do
		# check_installed sshpass
		clush -v -g "${i}" env DEBIAN_FRONTEND="noninteractive" sudo apt-get -y install sshpass curl
		log_header "Update the ${i} nodes  ------------------------------------------" && echo -e "\n"
		clush -v -g "${i}" sudo apt-get update
		log_header "Upgrade the ${i} nodes  ------------------------------------------" && echo -e "\n"
		clush -v -g "${i}" env DEBIAN_FRONTEND="noninteractive" sudo apt-get -y upgrade
		log_header "Autoremove on the ${i} nodes  ------------------------------------------" && echo -e "\n"
		clush -v -g "${i}" sudo apt-get -y autoremove
	done
}

function openbsd() {
	log_header "setup OpenBSD  ------------------------------------------" && echo -e "\n"
	ansible -m raw -a "pkg_add -y python" -b -i ./hosts blowfish.lab.bitsmasher.net
}

function main() {
	log_header "Preparing your environment, please stand by" && echo -e "\n"

	# [[ -n "${ANSIBLE_HOME}" ]] && ANSIBLE_HOME="${HOME}/workspace/lab-franklin/ansible" || log_warn "ANSIBLE_HOME env var is not set!"
	#[[ -n "${ANSIBLE_CONFIG}" ]] && ANSIBLE_CONFIG="${ANSIBLE_HOME}/ansible.cfg" || log_warn "ANSIBLE_CONFIG env var is not set!"
	if [ -z "${ANSIBLE_HOME+x}" ]; then
		log_warn "ANSIBLE_HOME is unset" && echo -e "\n"
		export ANSIBLE_HOME="/mnt/storage1/workspace/lab-franklin/ansible"
	else
		log_info "ANSIBLE_HOME is set to ${ANSIBLE_HOME}" && echo -e "\n"
	fi

  #echo -e "${LRED}$(figlet -d /usr/share/figlet -f block "Welcome to")${NC}\n"
  #echo -e "${LRED}$(figlet -d /usr/share/figlet -f block bitsmasher.net)${NC}\n"

	#check_container
	# configure_head_node
	# apt-get-target
	# configure_nvidia
	# openbsd

	log_header "RUNNING MAIN PLAYBOOK  ------------------------------------------" && echo -e "\n"
	ansible-playbook "${ANSIBLE_PLAYBOOK_DIR}/playbook.yml" -i ./hosts
}

main "$@"
