#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

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

k="/usr/bin/kubectl"

${k} delete service ctfd -n ctfd
${k} delete deployment ctfd -n ctfd
${k} delete pvc ctfd-pv-uploads -n ctfd
${k} delete pvc ctf-pv-logs -n ctfd
${k} delete backendconfig ctf-backend -n ctfd
# Services
${k} delete service ctfd-nginx -n ctfd
${k} delete service ctfd-redis-cache -n ctfd
${k} delete service ctfd-mysql-db -n ctfd
# Deployments
${k} delete deployment ctfd-nginx -n ctfd
${k} delete deployment ctfd-redis-cache -n ctfd
${k} delete deployment ctfd-mysql-db -n ctfd
#
${k} delete pvc ctfd-redis-cache-pv -n ctfd
${k} delete pvc ctfd-mysql-db-pv -n ctfd
${k} delete storageclass regionalpd-storageclass # this is a cluster scoped resource

${k} delete ingress ctfd -n ctfd
