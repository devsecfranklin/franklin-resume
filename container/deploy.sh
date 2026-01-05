#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2025 franklin 
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v0.1 | 29 Sept 2023 | franklin <smoooth.y62wj@passmail.net>
# v0.2 | 12/27/2025 | update for common.sh

set -o nounset  # Treat unset variables as an error
#set -euo pipefail

# The special shell variable IFS determines how Bash
# recognizes word boundaries while splitting a sequence of character strings.
#IFS=$'\n\t'


ns="kerberos" # specify a namespace
RED='\033[0;31m'
NC='\033[0m' # No Color

function namespace() {
    kubectl get po -n ${ns} | grep 'Running\|Completed'

    # below command to check the pods that are failed,terminated, error etc.
    kubectl get po -n ${ns} | grep -v Running | grep -v Completed
}

function main() {
  figlet -f "${HOME}/workspace/fonts/pagga" workspace && echo -e "\n"
  if [ -f "${HOME}/workspace/bin/common.sh" ]; then
    source "${HOME}/workspace/bin/common.sh"
  else
    echo -e "${LRED}can not find ${HOME}/workspace/bin/common.sh.${NC}"
    exit 1
  fi
  log_info "successfully sourced ${HOME}/workspace/bin/common.sh" && echo -e "\n"

    # prepare the namespace
    namespace

    kubectl create deployment kdc-server --image=ghcr.io/devsecfranklin/kdc-server:latest -n ${ns}

    # scale to 3 replicas
    kubectl scale deployment kdc-server --replicas=3 -n ${ns}

    # Create a HorizontalPodAutoscaler resource for your Deployment.
    kubectl autoscale deployment kdc-server --cpu-percent=80 --min=1 --max=5 -n ${ns}

    kubectl expose deployment kdc-server --name=kdc-server-svc --type=LoadBalancer --port 749 -n ${ns}
    kubectl expose deployment kdc-server --name=kdc-server-svc --type=LoadBalancer --port 88 --protocol=UDP -n ${ns}

    # show the external IP of the new service
    echo -e "${CYAN}Sleeping for 60 seconds to allow public IP assignment${NC}"

    sleep 60
    kubectl get service -n ${ns} kdc-server-svc
}

main "$@"