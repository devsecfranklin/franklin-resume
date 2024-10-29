#!/bin/bash

CURR_DIR="${PWD}"
cd /tmp && git clone --branch v1.10.5 https://github.com/rook/rook.git
cp /tmp/rook/deploy/examples/crds.yaml ${CURR_DIR}
cp /tmp/rook/deploy/examples/common.yaml ${CURR_DIR}
cp /tmp/rook/deploy/examples/operator.yaml ${CURR_DIR}
kubectl apply -f ${CURR_DIR}/crds.yaml -f ${CURR_DIR}/common.yaml
kubectl apply -f ${CURR_DIR}/operator.yaml

# wait a bit
kubectl get pod -n rook-ceph --output=wide

cp /tmp/rook/deploy/examples/cluster.yaml
kubectl apply -f ${CURR_DIR}/cluster.yaml

cp /tmp/rook/deploy/examples/csi/rbd/storageclass.yaml ${CURR_DIR}
