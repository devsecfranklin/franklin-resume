# Openstack

## Get Connected

* Two ways to connect to the instance.
  * `gcloud compute ssh --zone=us-central1-a openstack-franklin`
  * The IP of the instance is ephemeral and will change at each boot, so log in like so:

```sh
ssh -l ubuntu -i ~/.ssh/id_rsa_work $(terraform refresh | grep external_ip | cut -f2 -d'"')
```

## Install Openstack

* Install with devstack.

```sh
sudo groupadd stack
sudo usermod -a -G stack ubuntu
sudo usermod -a -G stack fdiaz_paloaltonetworks_com
cat /etc/group | grep stack
sudo mkdir -p /opt/stack && sudo chgrp stack /opt/stack
git clone https://git.openstack.org/openstack-dev/devstack /opt/stack
sudo /opt/stack/devstack/tools/create-stack-user.sh
su - stack
cd /opt/stack/devstack
```

* Create the `local.conf` devstack configuration file in `/opt/stack/devstack`

```sh
[[local|localrc]]

# Password for KeyStone, Database, RabbitMQ and Service
ADMIN_PASSWORD=StrongAdminSecret
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD

# Host IP - get your Server/VM IP address from ip addr command
HOST_IP=10.208.0.10
```

* Now kick off the devstack build.

```sh
./stack.sh
```

## Verify the Openstack Setup

To access OpenStack via a web browser browse your Ubuntu’s IP address: [https://server-ip/dashboard](https://server-ip/dashboard)

* Check for Ubuntu images like so `gcloud compute images list --filter 'family ~ ubuntu'`
