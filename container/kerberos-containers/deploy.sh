#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <thedevilsvoice@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# v0.1 - 29 Sept 2023

set -o nounset  # Treat unset variables as an error

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

RED='\033[0;31m'
#LRED='\033[1;31m'
#LGREEN='\033[1;32m'
CYAN='\033[0;36m'
#LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# specify a namespace
ns="kerberos"

function namespace() {
    kubectl get po -n ${ns} | grep 'Running\|Completed'

    # below command to check the pods that are failed,terminated, error etc.
    kubectl get po -n ${ns} | grep -v Running | grep -v Completed
}

function main() {

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

main
