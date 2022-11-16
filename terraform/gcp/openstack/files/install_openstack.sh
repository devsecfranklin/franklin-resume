#!/bin/bash

sudo apt update -y && sudo apt upgrade -y
#sudo apt-get install -y qemu-kvm
sudo apt install git -y
sudo apt autoremove -y
git clone https://git.openstack.org/openstack-dev/devstack /opt/stack

#cd /opt/openstack-ansible && git config --global --add safe.directory /opt/openstack-ansible && git checkout stable/ussuri
cd /opt/stack/devstack

cat <<EOF
[[local|localrc]]

# Password for KeyStone, Database, RabbitMQ and Service
ADMIN_PASSWORD=StrongAdminSecret
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD

# Host IP - get your Server/VM IP address from ip addr command
HOST_IP=10.208.0.10

EOF

# Need a pause here
# /opt/openstack-ansible/scripts/bootstrap-ansible.sh
# SCENARIO='aio_lxc_barbican_octavia' /opt/openstack-ansible/scripts/bootstrap-aio.sh
# openstack-ansible /opt/openstack-ansible/playbooks/setup-hosts.yml \
#    /opt/openstack-ansible/playbooks/setup-infrastructure.yml /opt/openstack-ansible/playbooks/setup-openstack.yml