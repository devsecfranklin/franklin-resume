#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

# The special shell variable IFS determines how Bash
# recognizes word boundaries while splitting a sequence of character strings.
#IFS=$'\n\t'

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
LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

HAS_IFCONFIG=false
HAS_IP=false
CONTAINER=false

# Check if we are inside a docker container
function check_docker() {
  if [ -f /.dockerenv ]; then
    echo -e "${CYAN}Containerized build environment...${NC}"
    CONTAINER=true
  else
    echo -e "${CYAN}NOT a containerized build environment...${NC}"
  fi
}

function check_installed() {
  if ! command -v ${1} &>/dev/null; then
    echo "${1} could not be found"
    #exit 1
  fi
}


function main() {
  check_docker
  # Container package installs will fail unless you do an initial update, the upgrade is optional
  if [ "${CONTAINER}" = true ]; then
    echo -e "${LBLUE}Upgrading container packages${NC}"
    apt-get update && apt-get upgrade -y
  fi

  # does ip command exist
  if check_installed ip; then
    HAS_IP=true
    echo "Found ip command"
  fi

  # does ifconfig cmd exist
  if check_installed ifconfig; then
    HAS_IFCONFIG=true
    echo "Found ip command"
  fi

  # check ICMP configuration
  # https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA10g000000ClIoCAK (Allow ICMP and ping - Palo FW)

  # in Google Cloud, a default gateway may not respond to pings or appear in traceroute results
  # because Google Cloud's software-defined networking reserves a virtual gateway IP address
  # for primary IP ranges in a VPC network's subnets.
  ICMP_ENABLED=$(cat /proc/sys/net/ipv4/icmp_echo_ignore_all) # It should output 0 which means ping is enabled, i.e. IPv4 ICMP echo request is not ignored.
  if [ ${ICMP_ENABLED} == "0" ]; then echo -e "${LBLUE}ICMP is enabled${NC}"; fi
  # sudo sysctl -w net.ipv4.icmp_echo_ignore_all=0 # fix ICMP
  # cat /etc/sysctl.conf # net.ipv4.icmp_echo_ignore_all=0 line should exist


  # find route command
  # get the routes
  /sbin/route -n

  # TCPDUMP
  check_installed tcpdump

  # use the -w flag to save to a file name
  #sudo tcpdump -D
  #sudo tcpdump --interface ens5
  #sudo tcpdump -i ens5 -c 5
  #sudo tcpdump -i ens5 -c5 icmp # filter by protocol
  #sudo tcpdump -i any -c5 -nn host 54.204.39.132 # Limit capture to only packets related to a specific host by using the host filter
  #sudo tcpdump -i any -c5 -nn src 10.236.20.20 # capture packets from a specific host

  # NMAP
  # check if installed
}

main "$@"
