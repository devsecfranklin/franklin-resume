#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

CA_DIR="/mnt/clusterfs/openssl/ca-bitsmasher.net"

rm ${CA_DIR}/certs/*-chain.pem ${CA_DIR}/certs/*.crt
rm ${CA_DIR}/private/*.key
rm ${CA_DIR}/csr/*.csr
rm ${CA_DIR}/csr/*.csr.conf
rm ca-bitsmasher.net/csr/*.csr
rm ca-bitsmasher.net/index.tx*
rm ca-bitsmasher.net/serial*

touch ${CA_DIR}/index.txt ${CA_DIR}/serial