#!/bin/bash

function create() {
  kubectl apply -f flask-pvc.yaml
  kubectl apply -f flask-deployment.yaml
}

function delete() {
  kubectl delete ingress -n cloud-tools cloud-tools
  kubectl delete service -n cloud-tools cloud-tools
}

echo "INGRESS:"
kubectl get ingress -n cloud-tools
echo "SERVICE:"
kubectl get service -n cloud-tools