#!/bin/bash

#set -o nounset                              # Treat unset variables as an error

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function chk_secret {
  if [ -z $(kubectl get secrets --all-namespaces | grep \"github-auth\") ]; then
    echo -e "\xE2\x9C\x94 ${LGREEN}Tekton GitHub secret found.${NC}"
  else
    echo -e "\xE2\x9D\x8C ${RED} Missing Tekton GitHub secret. Create the secret and do another terraform apply.${NC}"
    exit 1
  fi  
}

function chk_svc_acct {
  if [[ $(kubectl get serviceaccounts -n tekton-pipelines | grep "tekton-sa") ]]; then
    echo -e "\xE2\x9C\x94 ${LGREEN}Service Account tekton-sa found.${NC}"
  else
    echo -e "\xE2\x9D\x8C ${RED} Missing Tekton Service Account tekton-sa.${NC}"
    exit 1
  fi
  if [[ $(kubectl get roles -n tekton-pipelines | grep tekton-bot | cut -f1 -d" ") == "tekton-bot" ]]; then
    echo -e "\xE2\x9C\x94 ${LGREEN}Role tekton-bot found.${NC}"
  else
    echo -e "\xE2\x9D\x8C ${RED} Missing Role tekton-bot.${NC}"
    exit 1
  fi
  if [[ $(kubectl get rolebindings -n tekton-pipelines | grep tekton-role-binding | cut -f1 -d" ") == "tekton-role-binding" ]]; then
    echo -e "\xE2\x9C\x94 ${LGREEN}Cluster Role Binding tekton-role-binding found.${NC}"
  else
    echo -e "\xE2\x9D\x8C ${RED} Missing Cluster Role Binding tekton-role-binding.${NC}"
    exit 1
  fi
  if [ $(kubectl get clusterroles | grep tekton-bot-clusterrole | cut -f1 -d" ") == "tekton-bot-clusterrole" ]; then
    echo -e "\xE2\x9C\x94 ${LGREEN}Cluster Role tekton-bot-clusterrole found.${NC}"
  else
    echo -e "\xE2\x9D\x8C ${RED} Missing Cluster Role tekton-bot-clusterrole.${NC}"
    exit 1
  fi
  if [ $(kubectl get clusterrolebindings | grep tekton-bot-clusterbinding | cut -f1 -d" ") == "tekton-bot-clusterbinding" ]; then
    echo -e "\xE2\x9C\x94 ${LGREEN}Cluster Role Binding tekton-bot-clusterbinding found.${NC}"
  else
    echo -e "\xE2\x9D\x8C ${RED} Missing Cluster Role Binding tekton-bot-clusterbinding.${NC}"
    exit 1
  fi
}

function chk_storage {
  if [[ $(kubectl get configmaps -n tekton-pipelines| grep tekton-storage-configmap | cut -f1 -d" ") == "tekton-storage-configmap" ]]; then
    echo -e "\xE2\x9C\x94 ${LGREEN}ConfigMap tekton-storage-configmap found.${NC}"
  else
    echo -e "\xE2\x9D\x8C ${RED} Missing ConfigMap tekton-storage-configmap.${NC}"
    exit 1
  fi
  if [ $(kubectl get pvc -n tekton-pipelines | grep tekton-pvc | cut -f1 -d" ") == "tekton-pvc" ]; then
    echo -e "\xE2\x9C\x94 ${LGREEN}Persisten Volume Claim tekton-pvc found.${NC}"
  else
    echo -e "\xE2\x9D\x8C ${RED} Missing Persistent Volume Claim tekton-pvc.${NC}"
    exit 1
  fi
}

function main {
  chk_secret
  chk_svc_acct
  chk_storage
}

main
