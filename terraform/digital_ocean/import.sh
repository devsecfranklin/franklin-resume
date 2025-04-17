#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# set -euo pipefail

# The special shell variable IFS determines how Bash
# recognizes word boundaries while splitting a sequence of character strings.
IFS=$'\n\t'

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

DO_TOKEN=$(pass DO_TOKEN)
RECORDS="/tmp/dns_records.txt"

WWW=$(doctl compute droplet list | grep www | cut -f1 -d' ')
terraform import -var "do_token=${DO_TOKEN}" digitalocean_droplet.www ${WWW}

GAMES=$(doctl compute droplet list | grep games | cut -f1 -d ' ')
terraform import -var "do_token=${DO_TOKEN}" digitalocean_droplet.games ${GAMES}

doctl auth init
doctl compute domain records list bitsmasher.net > "${RECORDS}"

#terraform import -var "do_token=${DO_TOKEN}" digitalocean_domain.default bitsmasher.net
#terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.www bitsmasher.net,131134899


MX=$(grep MX "${RECORDS}" | cut -f1 -d ' ')
terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.mx bitsmasher.net,${MX}

PRO_VER=$(grep "protonmail-verification" "${RECORDS}" | cut -f1 -d ' ')
terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.txt1 bitsmasher.net,${PRO_VER}

SPF=$(grep spf "${RECORDS}" | cut -f1 -d ' ')
terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.txt2 bitsmasher.net,${SPF}

DMARC=$(grep "DMARC" "${RECORDS}" | cut -f1 -d ' ')
terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.txt3 bitsmasher.net,${DMARC}

DKIM1=$(grep "protonmail.domainkey" "${RECORDS}" | cut -f1 -d ' ')
terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.dkim1 bitsmasher.net,${DKIM1}

DKIM2=$(grep "protonmail.domainkey" "${RECORDS}" | cut -f1 -d ' ')
terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.dkim2 bitsmasher.net,${DKIM2}

DKIM3=$(grep "protonmail.domainkey" "${RECORDS}" | cut -f1 -d ' ')
terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.dkim3 bitsmasher.net,${DKIM3}

NS1=$(grep ns2 "${RECORDS}" | cut -f1 -d ' ')
for line in $NS1
do
  terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.ns1 bitsmasher.net,${line}
done

NS2=$(grep ns2 "${RECORDS}" | cut -f1 -d ' ')
for line in $NS2
do
  terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.ns2 bitsmasher.net,${line}
done


NS3=$(grep ns3 "${RECORDS}" | cut -f1 -d ' ')
for line in $NS3
do
  echo "adding record $line for ns3"
  terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.ns3 bitsmasher.net,${line}
done