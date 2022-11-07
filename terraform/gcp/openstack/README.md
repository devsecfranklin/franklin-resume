# Openstack

* Check for Ubuntu images like so `gcloud compute images list --filter 'family ~ ubuntu'`
* `gcloud compute ssh --zone=us-central1-a openstack-franklin`

## Microstack

[Set up on Ubuntu](https://ubuntu.com/openstack/install)

```sh
snap list microstack # verify the install
sudo microstack init --auto --control # initialize
sudo snap get microstack config.credentials.keystone-password # get horizon login (username admin)
```

* Run some commands

```sh
microstack.openstack image list
microstack.openstack flavor list
microstack.openstack keypair list
microstack.openstack network list
microstack.openstack security group rule list
```

* Launch instance

```sh
microstack.launch cirros --name franklin
ssh -i ~/.ssh/id_microstack cirros@<ip-address>

```
