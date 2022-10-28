#!/bin/bash -

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
