#!/bin/bash

NAMESPACE="kube-system"

kubectl logs -n ${NAMESPACE} pan-mgmt-sts-0
kubectl logs -n ${NAMESPACE} pan-mgmt-sts-1
