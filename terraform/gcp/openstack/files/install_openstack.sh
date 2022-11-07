#!/bin/bash

# Probably have to install from this script since it takes so long to come up

sudo apt-get update
#sudo apt-get install -y qemu-kvm
sudo apt autoremove -y
git clone https://opendev.org/openstack/openstack-ansible /opt/openstack-ansible

cd /opt/openstack-ansible && git config --global --add safe.directory /opt/openstack-ansible && git checkout stable/ussuri

# Need a pause here
/opt/openstack-ansible/scripts/bootstrap-ansible.sh

SCENARIO='aio_lxc_barbican_octavia' /opt/openstack-ansible/scripts/bootstrap-aio.sh

openstack-ansible /opt/openstack-ansible/playbooks/setup-hosts.yml \
    /opt/openstack-ansible/playbooks/setup-infrastructure.yml /opt/openstack-ansible/playbooks/setup-openstack.yml