# Openstack

* Check for Ubuntu images like so `gcloud compute images list --filter 'family ~ ubuntu'`
* `gcloud compute ssh --zone=us-central1-a openstack-franklin`
* The IP of the instance will change at each boot, but this works if you know the public IP:

```sh
ssh -l ubuntu -i ~/.ssh/id_rsa_work 34.70.70.44
```

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

## PanOS Install

* Get the Panorama image:

1. Login in to the Palo Alto Networks Customer Support Portal.
2. Select Updates -> Software Updates and choose Panorama Base Images from the Filter By drop-down.
3. Download the `Panorama-KVM-10.2.3.qcow2` file.
4. Create an image from the file.

```sh
sudo mv Panorama-KVM-10.2.3.qcow2  /var/snap/microstack/common/images/
microstack.openstack image create --min-ram 32 --min-disk 10 --disk-format qcow2 --container-format bare  --public --file /var/snap/microstack/common/images/Panorama-KVM-10.2.3.qcow2 panorama
```

* Verify:

```sh
ubuntu@openstack:~$ microstack.openstack image list
+--------------------------------------+----------+--------+
| ID                                   | Name     | Status |
+--------------------------------------+----------+--------+
| 30382c07-2774-4a6a-a758-2fb5f1078390 | cirros   | active |
| c00f4885-469f-40b3-a6e7-a9f8e501d62b | panorama | active |
+--------------------------------------+----------+--------+
```

* Now create an instance from the image:

```sh
fdiaz_paloaltonetworks_com@openstack:~$ microstack.launch -f m1.large -t test -n panorama-a panorama
Launching server ...
Allocating floating ip ...
Server panorama-a launched! (status is BUILD)

Access it with `ssh -i /home/fdiaz_paloaltonetworks_com/snap/microstack/common/.ssh/id_microstack <username>@10.20.20.138`
You can also visit the OpenStack dashboard at https://10.20.20.1:443
fdiaz_paloaltonetworks_com@openstack:~$
```

```sh
fdiaz_paloaltonetworks_com@openstack:~$ microstack.openstack flavor list
+----+-----------+-------+------+-----------+-------+-----------+
| ID | Name      |   RAM | Disk | Ephemeral | VCPUs | Is Public |
+----+-----------+-------+------+-----------+-------+-----------+
| 1  | m1.tiny   |   512 |    1 |         0 |     1 | True      |
| 2  | m1.small  |  2048 |   20 |         0 |     1 | True      |
| 3  | m1.medium |  4096 |   20 |         0 |     2 | True      |
| 4  | m1.large  |  8192 |   20 |         0 |     4 | True      |
| 5  | m1.xlarge | 16384 |   20 |         0 |     8 | True      |
+----+-----------+-------+------+-----------+-------+-----------+
```

## Horizon UI

* Get the microstack creds for Horizon UI.
* Username is `admin`.

```sh
🌖sudo snap get microstack config.credentials.keystone-password                                                           
```

## Remove

```sh
sudo snap stop microstack
sudo snap remove --purge microstack
```
