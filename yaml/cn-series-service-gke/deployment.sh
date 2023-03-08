#!/bin/bash

# 2/24/2023
# fdiaz@paloaltonetworks.com

set -o nounset                              # Treat unset variables as an error

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

#RED='\033[0;31m'
#LRED='\033[1;31m'
LGREEN='\033[1;32m'
CYAN='\033[0;36m'
#LPURP='\033[1;35m'
#YELLOW='\033[1;33m'
NC='\033[0m' # No Color

NAMESPACE="pa-cn"

function deploy() {
  echo -e "${LGREEN}create the service account${NC}"
  kubectl apply -f plugin-serviceaccount.yaml
  # cred.json will be uploaded to Panorama later
  kubectl -n pa-cn get secrets pan-plugin-user-secret -o json > cred.json
  kubectl apply -f pan-mgmt-serviceaccount.yaml
  kubectl apply -f pan-cni-serviceaccount.yaml
  kubectl apply -f pan-cni-configmap.yaml
  kubectl apply -f pan-cn-ngfw-svc.yaml
  kubectl apply -f pan-cni.yaml -n pa-cn
  # management
  kubectl apply -f pan-cn-mgmt-configmap.yaml
  kubectl apply -f pan-cn-mgmt-slot-crd.yaml
  kubectl apply -f pan-cn-mgmt-slot-cr.yaml
  kubectl apply -f pan-cn-mgmt-secret.yaml
  kubectl apply -f pan-cn-mgmt.yaml
  # firewalls
  kubectl apply -f pan-cn-ngfw-configmap.yaml
}

function status() {
  echo -e "${LGREEN}show the cluster role${NC}"
  kubectl get clusterrole | grep pan-plugin-crole
  # verify the secret from the last YAML (docs show wrong name)
  echo -e "${LGREEN}verify the secret from the last YAML${NC}"
  kubectl describe secret pan-plugin-user-secret -n ${NAMESPACE} | grep "token:"
  echo -e "${LGREEN}verify the service accounts${NC}"
  kubectl get serviceaccounts -n ${NAMESPACE} | grep pan-
  echo -e "${LGREEN}verify CNI configmap${NC}"
  kubectl get configmap  -n ${NAMESPACE} | grep pan-cni-config
  echo -e "${LGREEN}verify the pan-ngfw-service${NC}"
  kubectl get service -n ${NAMESPACE} | grep pan-ngfw-svc
  echo -e "${LGREEN}verify the CNI daemonset${NC}"
  kubectl get daemonsets -n ${NAMESPACE} | grep pan-cni
  echo -e "${LGREEN}verify the CNI pods${NC}"
  kubectl get pods -n ${NAMESPACE} | grep pan-cni
  #management
  echo -e "${LGREEN}verify the mgmt pods${NC}"
  kubectl get pods -l app=pan-mgmt -n ${NAMESPACE}
}

function main() {
  status
}

main