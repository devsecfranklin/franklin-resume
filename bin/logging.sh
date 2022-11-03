#!/bin/bash

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
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

shopt -s expand_aliases
alias k=$(which kubectl)
k=`which kubectl`

# SETUP Tasks
[ ! -d "`pwd`/yaml" ] && echo -e "${RED}run from top level of repo${NC}" && exit 1
command -v jq >/dev/null 2>&1 || { echo >&2 "${RED}Need to install jq.${NC}"; exit 1; }

# Namespace
NAMESPACE=$(${k} get ns logging -o json | jq .status.phase -r)
echo -e "${CYAN}Namespace: ${NAMESPACE}${NC}"
if [ ! "${NAMESPACE}" == "Active" ]; then
  kubectl create ns logging
  sleep 5
fi

# set context
echo -e "${CYAN}Setting Context: logging${NC}"
k config set-context --current --namespace=logging

# get the file then add the node Selector
# wget https://raw.githubusercontent.com/dstrebel/kbp/master/elasticsearch-operator.yaml
k apply -f yaml/elasticsearch-operator.yaml -n logging
# wget https://raw.githubusercontent.com/dstrebel/kbp/master/efk.yaml
# get the file then add the node Selector
k apply -f yaml/efk.yaml -n logging

sleep 5
echo -e "${LPURP}### ------------------- ###${NC}"
k get pods -n logging
