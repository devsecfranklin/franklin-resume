#/bin/bash

# 9/14/2022 franklin

#set -o nounset  # Treat unset variables as an error

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

k="/usr/bin/kubectl"

# SETUP Tasks
[ ! -d "`pwd`/yaml" ] && echo "${RED}run from top level of repo${NC}" && exit 1
command -v jq >/dev/null 2>&1 || { echo >&2 "${RED}Need to install jq.${NC}"; exit 1; }

# Namespace
NAMESPACE=$(${k} get ns ctfd -o json | jq .status.phase -r)
echo "${CYAN}Namespace: ${NAMESPACE}${NC}"
if [ ${NAMESPACE} != "Active" ]; then
  kubectl create ns ctfd
  sleep 5
fi

# set context
echo "${CYAN}Setting Context: ctfd${NC}"
${k} config set-context --current --namespace=ctfd

# Set up the storage class
echo "${CYAN}Set up StorageClass${NC}"
${k} apply -f yaml/ctfd-storage-class.yaml

# Deploy MySQL
echo "${CYAN}Set up MySQL${NC}"
${k} apply -f yaml/ctfd-mysql-deployment.yaml
sleep 5

# Deploy Redis
echo "${CYAN}Set up Redis${NC}"
${k} apply -f yaml/ctfd-redis-deployment.yaml
sleep 5

# Deploy Application
echo "${CYAN}Deploy CTFd${NC}"
${k} apply -f yaml/ctfd-deployment.yaml
sleep 5

# Deploy NGiNX
echo "${CYAN}Deploy NGiNx${NC}"
${k} apply -f yaml/ctfd-ngnix-deployment.yaml
sleep 5

# Status
# for x in `kubectl get pv | grep ctfd | cut -f1 -d' '`; do kubectl describe pv $x; done