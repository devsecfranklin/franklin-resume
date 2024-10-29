#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2024 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

yes | kubeadm reset
if [ -d "/tmp/etcd" ]; then
  rm -rf /tmp/etcd
fi
mv /var/lib/etcd /tmp

if [ -d "/tmp/kubernetes" ]; then
  rm -rf /tmp/kubernetes
fi
mv /etc/kuberbetes /tmp

rm -rf /etc/cni/net.d/*

if [ -f "${HOME}/.kube/config" ]; then
  rm ${HOME}/.kube/config
fi
