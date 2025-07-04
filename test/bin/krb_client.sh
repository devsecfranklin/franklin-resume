#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# v0.1 06/11/2021
# v0.2 11/30/2023

set -o nounset # Treat unset variables as an error

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
LCYAN='\033[1;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MY_DATE=$(date '+%Y-%m-%d-%H')
MY_OS="unknown"
CONTAINER=false

# Check if we are inside a docker container
function check_docker() {
  if [ -f /.dockerenv ]; then
    echo -e "${LGREEN}Building in container...${NC}"
    CONTAINER=true
  fi
}

function detect_os() {
  if [ -f "/etc/rpi-issue" ]; then
    echo -e "${LGREEN}Detected Raspberry Pi${NC}"
    MY_OS="rpi"
  elif [ "$(grep ^ID= /etc/os-release | cut -d= -f2)" == "ubuntu" ]; then
    # this one will match on the nvidia jetsons also
    echo -e "${LGREEN}Detected Ubunutu${NC}"
    MY_OS="ubuntu"
  elif [ "$(grep ^ID= /etc/os-release | cut -d= -f2)" == "pop" ]; then
    # this one is like debian or ubuntu
    echo -e "${LGREEN}Detected Pop OS${NC}"
    MY_OS="pop"
  elif [ "$(uname)" == "Darwin" ]; then
    echo -e "${LGREEN}Detected MacOS${NC}"
    MY_OS="mac"
  elif [ -f "/etc/redhat-release" ]; then
    echo -e "${LGREEN}Detected Red Hat/CentoOS/RHEL${NC}"
    MY_OS="rh"
  elif [ "$(grep -Ei 'debian|mint' /etc/*release)" ]; then
    echo -e "${CLGREEN}Detected Debian/Mint${NC}"
    MY_OS="deb"
  elif grep -q "Microsoft" /proc/version; then
    echo -e "${LGREEN}Detected Windows pretending to be Linux${NC}"
    MY_OS="win"
  elif [ "$(uname -s)" == "OpenBSD" ]; then
    echo -e "${LGREEN}Detected OpenBSD${NC}"
    MY_OS="obsd"
  else
    echo -e "${YELLOW}Unrecongnized architecture.${NC}"
    exit 1
  fi
}

function check_directory() {
  if [ -d "${1}" ]; then
    echo -e "${LGREEN}Directory exists: ${1}${NC}"
  else
    echo -e "${LRED}Directory missing: ${1}${NC}"
  fi
}

function check_file() {
  if [ -f "${1}" ]; then
    echo -e "${LGREEN}File exists: ${1}${NC}"
  else
    echo -e "${LRED}File missing: ${1}${NC}"
  fi
}

function check_service() {
  if "$(systemctl is-enabled ${1} &>/dev/null)"; then
    echo -e "${LGREEN}Running: ${1}${NC}"
  else
    echo -e "${LRED}NOT Running: ${1}${NC}"
  fi
}

function check_apt_package() {
  STATUS=$(dpkg-query -W --showformat='${Status}\n' ${1} | grep "ok installed")
  if [[ ${STATUS} == "install ok installed" ]]; then
    echo -e "${LGREEN}Package installed: ${1}${NC}"
  else
    echo -e "${LRED}Package NOT Installed: ${1}${NC}"
  fi
}

function check_ssh(){
  grep "GSSAPIAuthentication yes" /etc/ssh/ssh_config
  grep "GSSAPIKeyExchange yes" /etc/ssh/ssh_config
  grep "GSSAPITrustDNS yes" /etc/ssh/ssh_config
}

function main() {
  echo -e "\n${LCYAN}# --- kdc_check.sh --- ${YELLOW}DATE: ${MY_DATE} ${LCYAN}---------------\n${NC}"
  check_docker
  detect_os

  HOSTNAME=$(hostname)

  if [[ $MY_OS == "obsd" ]]; then
    echo -e "${LPURP}This is an OpenBSD system: ${HOSTNAME}${NC}"
    check_file "/etc/heimdal/krb5.keytab"
    check_file "/etc/heimdal/krb5.conf"
  elif [[ $MY_OS == "mac" ]]; then
    echo -e "${LPURP}This is an Mac system: ${HOSTNAME}${NC}"
  elif [[ $MY_OS == "rpi" || $MY_OS == "deb" ]]; then
    echo -e "${LPURP}This is a Debian system: ${HOSTNAME}${NC}"
    check_file "/etc/krb5.keytab"
    check_file "/etc/krb5.conf"
    check_file "${HOME}/.k5login"
    check_apt_package "krb5-user" # ksu
    check_apt_package "krb5-config"
    echo -e "\n${LGREEN}Current klist:${NC}"
    klist -f
  else
    echo -e "${RED}Unknown system: ${HOSTNAME}${NC}"
  fi
  echo -e "\n${LCYAN}# -------------------- ${YELLOW}DATE: ${MY_DATE} ${LCYAN}---------------\n${NC}"
}

main "$@"
