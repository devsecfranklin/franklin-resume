#!/usr/bin/env bash -
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <thedevilsvoice@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -o nounset # Treat unset variables as an error

cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Secret
metadata:
  name: basic-user-pass
  annotations:
    tekton.dev/git-0: https://github.com # Described below
type: kubernetes.io/basic-auth
stringData:
  username: $(pass show gh-username)
  password: $(pass show gh-password)
EOF
