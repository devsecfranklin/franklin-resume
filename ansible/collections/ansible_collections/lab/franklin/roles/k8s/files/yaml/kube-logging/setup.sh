#!/bin/bash

kubectl create -f es-svc.yaml
kubectl create -f es-sts.yaml

# wait a while before you run this
kubectl get pods -n logging

# Verify ES cluster
# 1. Run this in terminal
# kubectl port-forward es-cluster-0 9200:9200
# 2. Run this in another terminal with port fwd running
# curl http://localhost:9200/_cluster/health/?pretty


# Kibana
kubectl create -f kibana-deployment.yaml


# Verify Kibana
# kubectl port-forward <kibana-pod-name> 5601:5601
# curl http://localhost:5601/app/kibana


kubectl create -f fluentd-role.yaml
kubectl create -f fluentd-sa.yaml
kubectl create -f fluentd-rb.yaml
kubectl create -f fluentd-ds.yaml


# kubectl port-forward kibana-5b486549d4-w8cnx 5601:5601
# http://localhost:5601/app/kibana#/home?_g=()
