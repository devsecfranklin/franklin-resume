#!/bin/bash

GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
sudo k3s kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml

sudo k3s kubectl create -f dashboard.admin-user.yml -f dashboard.admin-user-role.yml

# Get the token
# sudo k3s kubectl -n kubernetes-dashboard create token admin-user # for 1.24 or newer
sudo k3s kubectl -n kubernetes-dashboard describe secret admin-user-token | grep '^token'

kubectl port-forward pods/kubernetes-dashboard-658b66597c-rhp7f -n kubernetes-dashboard 8443:8443 --address='10.10.12.18'

# https://head1:8443/#/login

function delete_dashboard() {
  sudo k3s kubectl delete ns kubernetes-dashboard
  sudo k3s kubectl delete clusterrolebinding kubernetes-dashboard
  sudo k3s kubectl delete clusterrole kubernetes-dashboard
}

function upgrade_dashboard() {
  sudo k3s kubectl delete ns kubernetes-dashboard
  GITHUB_URL=https://github.com/kubernetes/dashboard/releases
  VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
  sudo k3s kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml -f dashboard.admin-user.yml -f dashboard.admin-user-role.yml
}
