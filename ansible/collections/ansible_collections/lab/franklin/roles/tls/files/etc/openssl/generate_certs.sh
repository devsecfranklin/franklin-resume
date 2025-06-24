#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2021-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

#set -euo pipefail

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

#RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

HOSTS=(head2 node0 node1 node2 node3 node5 node6 time)
WORKDIR="/etc/openssl"
CERT_DIR="${WORKDIR}/certs"
JSON_DIR="${WORKDIR}/json"

function create_intermediate() {
  cd "$CERT_DIR/intermediate1"
  cfssl genkey -initca "${CERT_DIR}/intermediate1/config.json" | cfssljson -bare intermediate1
  # sign intermediate cert
  cfssl sign -ca ${WORKDIR}/ca.pem -ca-key ../ca-key.pem -profile intermediate --config ${JSON_DIR}/profiles.json "${CERT_DIR}/intermediate/intermediate1.csr" | cfssljson -bare intermediate1
  openssl x509 -in "${CERT_DIR}/intermediate1/intermediate1.pem" -noout -text # inspect new cert
}

function main() {
  echo "Workdir: $WORKDIR"
  echo "Copying latest files out of ansible"
  #cd /etc && (yes | cp -r /mnt/storage1/workspace/lab-franklin/ansible/collections/ansible_collections/lab/franklin/roles/tls/files/etc/openssl .)
  cd $WORKDIR

  for i in "${HOSTS[@]}"; do
    echo -e "\n${LPURP}# --- prepare certificate for ${i} -------------------------------------------\n${NC}"

    if [ ! -d "./${i}" ]; then mkdir -p "${WORKDIR}/${i}"; else echo -e "${LGREEN}folder exists: ${i}${NC}"; fi
    echo -e "\n${LPURP}# --- generate ${i}/${i}-csr.json ${i} -------------------------------------------\n"

  cat >"${WORKDIR}/${i}/${i}-csr.json" <<EOF
  {
      "CN": "${i}",
      "hosts": [
          "${i}",
          "${i}.lab.bitsmasher.net"
      ],
      "key": {
          "algo": "rsa",
          "size": 2048
      },
      "names": [
          {
              "C": "US",
              "L": "CO",
              "ST": "Denver"
          }
      ]
  }
EOF

    if [ -f "${WORKDIR}/${i}/${i}-csr.json" ]; then echo -e "${LGREEN}Success creating ${WORKDIR}/${i}/${i}-csr.json${NC}"; else echo -e "${LRED}FAILED to create ${WORKDIR}/${i}/${i}-csr.json${NC}" && exit 1; fi

    echo -e "\n${LPURP}# --- check for needed files -------------------------------------------\n${NC}"
    FILES=("${WORKDIR}/ca.pem" "${WORKDIR}/ca-key.pem" "${WORKDIR}/ca-config.json")
    for j in "${FILES[@]}"; do
      if [ ! -f "${j}" ]; then
        echo "Missing file: ${j}" && exit 1
      else
        echo -e "${LGREEN}Found required file: ${j}"
      fi
    done
    echo -e "\n${LPURP}# --- Now generate cert for ${i} -------------------------------------------\n${LGREEN}"
    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server ca-csr.json | cfssljson -bare server
    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -hostname="${i}.lab.bitsmasher.net" -profile=server "${i}/${i}-csr.json" | cfssljson -bare "${i}/${i}"
    echo -e "\n${LPURP}# --- SUCCESS: created ${i}/${i}.pem -------------------------------------------\n${NC}"
    cfssl-certinfo -cert "${i}/${i}.pem"
    openssl x509 -in "${i}/${i}.pem" -noout -text # inspect the cert and the chain to make sure everything is correct

  done
}

main "$@"
