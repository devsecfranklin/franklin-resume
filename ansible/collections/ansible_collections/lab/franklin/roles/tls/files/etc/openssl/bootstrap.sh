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

WORKDIR="/etc/openssl"

pushd "${WORKDIR}" || exit 1

echo -e "\n${LPURP}# --- check cfssl install -------------------------------------------\n${NC}"
[ -f "/home/franklin/go/bin/cfssl" ] || (go install github.com/cloudflare/cfssl/cmd/...@latest || exit 1)

echo -e "\n${LPURP}# --- copy latest files from ansible -------------------------------------------\n${NC}"
yes | cp -r /mnt/storage1/workspace/lab-franklin/ansible/collections/ansible_collections/lab/franklin/roles/tls/files/etc/openssl  /etc


echo -e "\n${LPURP}# --- generate ca.key -------------------------------------------\n${LGREEN}"
# openssl ecparam # list_curves
#openssl genrsa -out ca.key 
openssl ecparam -out "${WORKDIR}/root-ca.key" -name prime256v1 -genkey
openssl req -new -key "${WORKDIR}/root-ca.key" -x509 -nodes -days 365 -out "${WORKDIR}/root-cert.key" 

echo -e "\n${LPURP}# --- generate ca.crt -------------------------------------------\n${LGREEN}"
# openssl req -x509 -new -nodes -key ca.key -sha256 -days 1825 -out ca.crt
openssl req -x509 -new -nodes -key "${WORKDIR}/root-ca.key" -sha256 -days 1825 -out "${WORKDIR}/root-ca.crt"

echo -e "\n${LPURP}# --- generate csr.conf -------------------------------------------\n${LGREEN}"
cat >csr.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = US
ST = Colorado
L = Denver
O = franklin
OU = engr
CN = bitsmasher.net

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = head2
DNS.2 = head2.lab.bitsmasher.net
IP.1 = 10.10.12.19

EOF

echo -e "\n${LPURP}# --- generate server.key -------------------------------------------\n${LGREEN}"
openssl genrsa -out server.key 2048

echo -e "\n${LPURP}# --- generate server.crt -------------------------------------------\n${LGREEN}"
openssl x509 -req -in server.csr -CA "${WORKDIR}/root-ca.crt" -CAkey "${WORKDIR}/root-ca.key" -CAcreateserial -out server.crt -days 10000 -extfile csr.conf

mkdir -p "${WORKDIR}/cfssl" && (pushd "${WORKDIR}/cfssl" || exit 1)

echo -e "\n${LPURP}# --- generate cfssl/ca-csr.json -------------------------------------------\n${LGREEN}"
# this json includes the required data for a ECDSA root certificate for bitsmasher.net
cat >/etc/openssl/cfssl/ca-csr.json <<EOF
{
  "CN": "bitsmasher.net CA",
  "key": {
    "algo": "ecdsa",
    "size": 384
  },
  "CA": {
    "expiry": "87660h",
    "pathlen": 2
  },
  "names": [
    {
      "C": "US",
      "L": "Colordao",
      "ST": "Denver",
      "O": "research",
      "OU": "lab"
    }
  ]
}
EOF

echo -e "\n${LPURP}# --- review defaults -------------------------------------------\n${LGREEN}"
cfssl print-defaults config
cfssl print-defaults csr

echo -e "\n${LPURP}# --- initialize the certificate authority -------------------------------------------\n${LGREEN}"
# tells cfssl that we want to generate a new certificate (keys and sign request) and by using the -initca option
# we also tell it that the certificate will be used for a certificate authority.
# cfssl gencert -initca /etc/openssl/cfssl/ca-csr.json | cfssljson -bare ca –
cfssl gencert -initca /etc/openssl/cfssl/ca-csr.json | cfssljson -bare root

echo -e "\n${LPURP}# --- create cfssl/ca-config.json -------------------------------------------\n${LGREEN}"
cat >/etc/openssl/cfssl/ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "hosts": [
      "head2.lab.bitsmasher.net",
      "node0.lab.bitsmasher.net"
  ],
    "profiles": {
      "intermediate_ca": {
        "usages": [
            "signing",
            "digital signature",
            "key encipherment",
            "cert sign",
            "crl sign",
            "server auth",
            "client auth"
        ],
        "expiry": "8760h",
        "ca_constraint": {
            "is_ca": true,
            "max_path_len": 0, 
            "max_path_len_zero": true
        }
      },
      "server": {
        "usages": [
          "signing",
          "digital signing",
          "key encipherment",
          "server auth"
        ],
        "expiry": "8760h"
      },
      "client": {
        "usages": [
          "signing",
          "digital signature",
          "key encipherment", 
          "client auth"
        ],
        "expiry": "8760h"
      }
    }
  }
}
EOF

echo -e "\n${LPURP}# --- generate cfssl/head2/head2-csr.json -------------------------------------------\n${LGREEN}"
mkdir -p /etc/openssl/cfssl/head2
cat >/etc/openssl/cfssl/head2/head2-csr.json <<EOF
{
  "CN": "head2",
  "hosts": [
      "head2",
      "head2.lab.bitsmasher.net"
  ],
  "key": {
      "algo": "edcsa",
      "size": 348
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

echo -e "\n${LPURP}# --- generate intermediate certificate -------------------------------------------\n${LGREEN}"
mkdir -p /etc/openssl/cfssl/intermediate1
cat >/etc/openssl/cfssl/intermediate1/server.json <<EOF
{
    "CN": "Server",
    "hosts": [
        "127.0.0.1",
        "bitsmasher.net",
        "lab.bitsmasher.net"
    ]
}
EOF

mkdir -p /etc/openssl/cfssl/client
cat >/etc/openssl/cfssl/intermediate1/client.json <<EOF
{
    "CN": "Client",
    "hosts": [""]
}
EOF

# generate
cfssl gencert -ca=intermediate1.pem -ca-key=intermediate1-key.pem -config=../profiles.json -profile=server server.json | cfssljson -bare server
openssl x509 -in server.pem -noout -text
cfssl gencert -ca=intermediate1.pem -ca-key=intermediate1-key.pem -config=../profiles.json -profile=client client.json | cfssljson -bare client
openssl x509 -in client.pem -noout -text
