#!/bin/bash

MY_IP=`curl icanhazip.com`

echo "Public IP of this instance: ${MY_IP}"

microstack.openstack image list
microstack.openstack flavor list
microstack.openstack keypair list
microstack.openstack network list
microstack.openstack security group rule list
