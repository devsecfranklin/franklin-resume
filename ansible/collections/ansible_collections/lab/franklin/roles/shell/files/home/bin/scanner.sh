#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

if [[ -z $1 ]]; then
  echo "usage $0 network-list [tcp/upd]"
  exit
fi

mode=""
if [[ -z $2 ]]; then
  mode=tcp
else
  mode=$2
fi

# backup any old scans before we start a new one
mkdir -p backup
if [[ -d ndir ]]; then
  mv ndir backup/ndir-$(date "+%Y%m%d-%H%M%S")
fi
if [[ -d udir ]]; then
  mv udir backup/udir-$(date "+%Y%m%d-%H%M%S")
fi

rm -rf ndir
mkdir -p ndir
rm -rf udir
mkdir -p udir

for ip in $(cat $1); do
  ports=""
  echo "[+] scanning ${ip} for $mode ports..."

  # unicornscan identifies all open ports
  if [[ $mode == "tcp" ]]; then
    echo "[+] obtaining all open $mode ports using unicornscan..."
    echo "[+] unicornscan -msf ${ip}:a -l udir/${ip}-tcp.txt"
    unicornscan -msf ${ip}:a -l udir/${ip}-tcp.txt
    ports=$(cat udir/${ip}-tcp.txt | grep open | cut -d"[" -f2 | cut -d"]" -f1 | sed 's/ //g' | tr '\n' ',')
  else
    echo "[+] obtaining all open $mode ports using unicornscan..."
    echo "[+] unicornscan -mU ${ip}:a -l udir/${ip}-udp.txt"
    unicornscan -mU ${ip}:a -l udir/${ip}-udp.txt
    ports=$(cat udir/${ip}-udp.txt | grep open | cut -d"[" -f2 | cut -d"]" -f1 | sed 's/ //g' | tr '\n' ',')
  fi

  # nmap follows up on any open ports unicornscan found
  if [[ ! -z $ports ]]; then
    echo "[+] ports for nmap to scan: $ports"
    if [[ $mode == "tcp" ]]; then
      echo "[+] nmap -sV -oX ndir/${ip}-tcp.xml -oG ndir/${ip}-tcp.grep -p ${ports} ${ip}"
      nmap -sV -sC -O -sT -vvv -oX ndir/${ip}-tcp.xml -oG ndir/${ip}-tcp.grep -p ${ports} ${ip}
    else
      echo "[+] nmap -sU -oX ndir/${ip}-udp.xml -oG ndir/${ip}-udp.grep -p ${ports} ${ip}"
      nmap -sU -oX ndir/${ip}-udp.xml -oG ndir/${ip}-udp.grep -p ${ports} ${ip}
    fi
  else
    echo "[+] no open ports found"
  fi
  echo ""
done
echo "[+] scans completed"
