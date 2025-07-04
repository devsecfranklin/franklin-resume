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

WORKDIR="/etc/openssl/ca-bitsmasher.net"

function create_folders() {
  echo -e "\n${LPURP}# --- create certificate folders -------------------------------------------\n${LGREEN}"
  if [ ! -d "${WORKDIR}" ]; then
    mkdir -p "${WORKDIR}"
  fi
  touch "${WORKDIR}/index.txt"   # This acts as a database for signed certificates.
  echo 1000 >"${WORKDIR}/serial" # This file holds the next serial number for certificates
  ln -s /etc/openssl/openssl.cnf "${WORKDIR}/openssl.cnf"
  mkdir -p "${WORKDIR}/certs"    # to store issued certificates
  mkdir -p "${WORKDIR}/crl"      # to store certificate revocation lists
  mkdir -p "${WORKDIR}/newcerts" # To store newly issued certificates (temporary).
  mkdir -p "${WORKDIR}/private"  # To store private keys (keep this secured!).
  mkdir -p "${WORKDIR}/csr"      # to store certificate signing requests
}

function setup_cfssl() {
  echo -e "\n${LPURP}# --- check cfssl install -------------------------------------------\n${NC}"
  [ -f "/home/franklin/go/bin/cfssl" ] || (echo -e "\n${LBLUE}installing golang cfssl\n${NC}" && go install github.com/cloudflare/cfssl/cmd/...@latest || exit 1)
}

# function ansible_kludge() {
#   echo -e "\n${LPURP}# --- copy latest files from ansible -------------------------------------------\n${NC}"
#   yes | cp -r /mnt/storage1/workspace/lab-franklin/ansible/collections/ansible_collections/lab/franklin/roles/tls/files/etc/openssl /etc
# }

# root CA private key
function root_ca() {

  #echo -e "\n${LPURP}# --- initialize the certificate authority -------------------------------------------\n${LGREEN}"
  # tells cfssl that we want to generate a new certificate (keys and sign request) and by using the -initca option
  # we also tell it that the certificate will be used for a certificate authority.
  # cfssl gencert -initca /etc/openssl/cfssl/ca-csr.json | cfssljson -bare ca –
  #cfssl gencert -initca /etc/openssl/cfssl/ca-csr.json | cfssljson -bare root

  echo -e "\n${LPURP}# --- generate ca.key -------------------------------------------\n${LGREEN}"
  # openssl ecparam # list_curves
  # openssl genrsa -out ca.key
  if [ ! -f "${WORKDIR}/private/root-ca.key" ]; then
    echo -e "\n${LBLUE}Creating ${WORKDIR}/private/root-ca.key\n${NC}"
    openssl ecparam -out "${WORKDIR}/private/root-ca.key" -name prime256v1 -genkey
    # openssl req -new -key "${WORKDIR}/private/root-ca.key" -x509 -nodes -days 365 -out "${WORKDIR}/private/root-ca.key"
    # openssl genrsa -aes256 -out "${WORKDIR}/private/root-ca.key"  4096
    # Or using genpkey for more modern algorithms like EC:
    # openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -aes256 -out "${WORKDIR}/private/root-ca.key"

  else
    echo -e "\n${LBLUE}already exist ${WORKDIR}/private/root-ca.key\n${NC}"
  fi
  openssl ec -text -noout -check -in "${WORKDIR}/private/root-ca.key"  # validate
}

# This is the public certificate of your Root CA. It contains the public key corresponding to rootCA.key
# and is used to verify certificates signed by this CA. This is the file you distribute to clients/browsers
# so they trust your local CA.
function gen_ca_crt() {
  echo -e "\n${LPURP}# --- generate ca.crt -------------------------------------------\n${LGREEN}"

  echo -e "\n${LBLUE}creating ${WORKDIR}/certs/root-ca.crt\n${NC}"
  # openssl ca -config "${WORKDIR}/openssl.cnf" -in "${WORKDIR}/csr/csr.conf" -out "${WORKDIR}/certs/root-ca.crt"
  openssl req -x509 -new -nodes -key "${WORKDIR}/private/root-ca.key" -out "${WORKDIR}/certs/root-ca.crt" -config "${WORKDIR}/openssl.cnf" # -extensions v3_ca
  #openssl req -x509 -new -nodes -key "${WORKDIR}/private/root-ca.key" -out "${WORKDIR}/certs/root-ca.crt" -subj "/C=US/ST=CO/L=Denver/O=research/CN=franklin" # -extensions v3_ca

  if [ ! -f "${WORKDIR}/certs/root-ca.crt" ]; then
    echo -e "\n${LRED}FAIL to generate root certificate.${NC}"
    exit 1
  else
    echo -e "\n${LBLUE}created ${WORKDIR}/certs/root-ca.crt\n${NC}"
    openssl x509 -in "${WORKDIR}/certs/root-ca.crt" -text -noout
  fi
  openssl x509 -in "${WORKDIR}/certs/root-ca.crt" -noout -text
}

function intermediate_ca() {
  echo -e "\n${LPURP}# --- intermediate certs -------------------------------------------\n${LGREEN}"
  if [ ! -f "${WORKDIR}/private/intermediate-ca.key" ]; then
    echo -e "\n${LBLUE}creating ${WORKDIR}/private/intermediate-ca.key\n${NC}"
    # openssl genrsa -aes256 -out "${WORKDIR}/private/intermediate-ca.key" 2048 # Intermediate CA Private Key
    openssl ecparam -out "${WORKDIR}/private/intermediate-ca.key" -name prime256v1 -genkey
  else
    echo -e "\n${LBLUE}already exist ${WORKDIR}/private/intermediate-ca.key\n${NC}"
  fi
  openssl req -new -sha256 -key "${WORKDIR}/private/intermediate-ca.key" -out "${WORKDIR}/csr/intermediate-ca.csr" -config "${WORKDIR}/openssl.cnf" # Intermediate CA Certificate Signing Request (CSR)
  # openssl ca -batch -config "${WORKDIR}/openssl.cnf" -extensions v3_ca -days 730 -notext -md sha256 -in "${WORKDIR}/csr/intermediate-ca.csr" -out "${WORKDIR}/certs/intermediate-ca.crt" -extensions v3_ca -extfile "${WORKDIR}/csr/csr.conf"
}

function machine_certs() {
  # is this a server or a client?
  DEB_HOSTS=(head2 ldap node0 node1 node2 node3 node5 node6 snowy thelio time)
  for MY_HOST in "${DEB_HOSTS[@]}"; do
    echo -e "\n${LPURP}# --- generate ${MY_HOST}.key -------------------------------------------\n${LGREEN}"
    openssl genrsa -aes256 -out "${WORKDIR}/private/${MY_HOST}.key" 2048 # generate a private key

    IP=$(grep "${MY_HOST}" /etc/hosts | cut -f1 -d' ')
    echo -e "\n${LPURP}# --- generate ${MY_HOST}.csr -------------------------------------------\n${LGREEN}"
    cat >"${WORKDIR}/csr/${MY_HOST}.csr" <<EOF
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
O = research
OU = lab
CN = ${MY_HOST}.lab.bitsmasher.net

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${MY_HOST}
DNS.2 = ${MY_HOST}.lab.bitsmasher.net
IP.1 = ${IP}

EOF

    # Server/Client Certificate Signing Request (CSR) (server.csr or client.csr):
    echo -e "\n${LPURP}# --- generate ${MY_HOST}.crt -------------------------------------------\n${LGREEN}"
    # openssl req -new -sha256 -key "${WORKDIR}/private/${MY_HOST}.key" -out "${WORKDIR}/csr/${MY_HOST}.csr" -config "${WORKDIR}/openssl.cnf" -reqexts server_cert_req
    # cfssl gencert -ca=intermediate1.pem -ca-key=intermediate1-key.pem -config=../profiles.json -profile=server server.json | cfssljson -bare server
    # openssl x509 -in server.pem -noout -text
    # cfssl gencert -ca=intermediate1.pem -ca-key=intermediate1-key.pem -config=../profiles.json -profile=client client.json | cfssljson -bare client
    # openssl x509 -in client.pem -noout -text
    # openssl x509 -req -in "${WORKDIR}/csr/${MY_HOST}.csr" -CA "${WORKDIR}/certs/root-ca.crt" -CAkey "${WORKDIR}/private/root-ca.key" -CAcreateserial -out "${WORKDIR}/certs/${MY_HOST}.crt" -days 10000 -extfile "${WORKDIR}/csr/csr.conf"

    # If using an intermediate CA to sign:
    # openssl ca -batch -config "${WORKDIR}/openssl.cnf" -extensions server_cert -days 365 -notext -md sha256 \
    #  -in "${WORKDIR}/csr/${MY_HOST}.csr" -out "${WORKDIR}/certs/${MY_HOST}.crt"
    openssl ca -batch -config "${WORKDIR}/openssl.cnf" -days 730 -notext -md sha256 \
      -in "${WORKDIR}/csr/${MY_HOST}.csr" -out "${WORKDIR}/certs/${MY_HOST}.crt" -extfile "${WORKDIR}/csr/csr.conf"

    # If signing directly with the Root CA (less common, but possible):
    # openssl x509 -req -in server.csr -CA certs/rootCA.crt -CAkey private/rootCA.key -CAcreateserial \
    # -out certs/server.crt -days 365 -sha256 -extfile openssl.cnf -extensions server_cert

    if [ ! -f "${WORKDIR}/certs/${MY_HOST}.crt" ]; then
      echo -e "\n${LRED}FAIL to generate ${MY_HOST} certificate. Did not find file: ${WORKDIR}/certs/${MY_HOST}.crt ${NC}\n"
      exit 1
    else
      echo -e "\n${LBLUE}created ${WORKDIR}/certs/${MY_HOST}.crt\n${NC}"
      openssl x509 -in "${WORKDIR}/certs/${MY_HOST}.crt" -text -noout
    fi

    cat "${WORKDIR}/certs/${MY_HOST}.crt" "${WORKDIR}/certs/intermediate-ca.crt" >"${WORKDIR}/certs/${MY_HOST}-chain.pem"
    sudo cp "${WORKDIR}/certs/root-ca.crt" /usr/local/share/ca-certificates/root-ca.crt
    # sudo update-ca-certificates
  done
}

function validation() {
  # echo -e "\n${LPURP}# --- review defaults -------------------------------------------\n${LGREEN}"

  # cfssl print-defaults config
  # cfssl print-defaults csr
  MOD_PUB=$(openssl req -in "${WORKDIR}/certs/root-ca.crt" -noout -modulus | openssl md5)     # Check the Modulus of the Public Key in the Certificate
  MOD_PRIV=$(openssl pkey -in "${WORKDIR}/private/root-ca.key" -noout -modulus | openssl md5) # Check the Modulus of the Private Key
  if [ "${MOD_PRIV}" != "${MOD_PUB}" ]; then
    # what happens if you generated a new private key but didn't re-generate the CA certificate using that new key
    echo -e "\n${LRED}FAIL since ${MOD_PRIV} and ${MOD_PUB} do not match.${NC}" && exit 1
  fi

  # compare these two values they should match
  openssl req -noout -modulus -in "${WORKDIR}/csr/time.csr" | openssl md5
  openssl pkey -noout -modulus -in "${WORKDIR}/private/time.key" | openssl md5

}

function main() {
  create_folders
  pushd "${WORKDIR}" || exit 1
  # ansible_kludge
  setup_cfssl
  root_ca
  gen_ca_crt
  intermediate_ca
  machine_certs
}

main "$@"
