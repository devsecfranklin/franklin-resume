#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

DMZ="192.168.0.0/24"
LAN="10.10.8.0/21"
WORKDIR="/tmp"

nmap -sn "${DMZ}" | tee "${WORKDIR}/results-dmz.log"
#nmap -PR "${DMZ}" | tee -a "${WORKDIR}/results-dmz.log"
grep "Nmap scan report for" "${WORKDIR}/results-dmz.log" | cut -f6 -d' ' | tr -d '()' > ${WORKDIR}/dmz-ips.log

nmap -sn "${LAN}" | tee "${WORKDIR}/results-lan.log"
#nmap -PR "${LAN}" | tee -a "${WORKDIR}/results-lan.log"
grep "Nmap scan report for" "${WORKDIR}/results-lan.log" | cut -f6 -d' ' | tr -d '()' > ${WORKDIR}/lan-ips.log
 