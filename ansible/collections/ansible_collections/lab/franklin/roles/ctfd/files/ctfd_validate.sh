#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# 03 Nov 2022 franklin@dead10c5.org

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

shopt -s expand_aliases
alias k=$(which kubectl)

echo -e "${CYAN}----- Showing CTFd pods -----${NC}"
k get pods -n ctfd --output=wide | grep ctfd | cut -f1 -d' '

echo -e "${CYAN}----- Showing CTFd svcs -----${NC}"
kubectl get services -n ctfd

echo -e "${CYAN}----- Showing CTFd deployments -----${NC}"
kubectl get deployments -n ctfd

echo -e "${CYAN}----- Showing CTFd Public IP -----${NC}"
gcloud compute addresses list 2>&1 | grep ctfd

echo -e "${CYAN}----- Check the CTFd Ingress -----${NC}"
#k get ingress -n ctfd
kubectl describe ingress -n ctfd ctfd

echo -e "${CYAN}----- Get the CTFd svcneg -----${NC}"
kubectl get svcneg -n ctfd
