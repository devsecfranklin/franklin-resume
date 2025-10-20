# Playbooks

## NFS Snowy

```sh
ansible-playbook /home/franklin/workspace/LAB/lab-franklin/ansible/collections/ansible_collections/lab/franklin/playbooks/snowy.yml -i /etc/ansible/hosts
```

## Raspi Cluster

```sh
ansible-playbook /home/franklin/workspace/LAB/lab-franklin/ansible/collections/ansible_collections/lab/franklin/playbooks/cluster_raspi.yml -i /etc/ansible/hosts -b -e 'ansible_python_interpreter=/usr/bin/python3'
```
