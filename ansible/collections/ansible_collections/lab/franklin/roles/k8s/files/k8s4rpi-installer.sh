#!/bin/bash

echo "disable swap"
swapoff -a
dphys-swapfile swapoff
dphys-swapfile uninstall
update-rc.d dphys-swapfile remove
apt purge -y dphys-swapfile

echo "update repo and install curl"
apt-get update && apt-get install -y apt-transport-https curl

echo "set net.bridge.bridge-nf-call-iptables=1"
cat <<EOF >/etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
EOF

echo "install docker"
curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
usermod -aG docker pi

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload
systemctl restart docker

echo "add repos"
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-get update

echo "install k8s packages"
apt-get install -y kubelet kubeadm kubectl
