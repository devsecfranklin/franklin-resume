# Ansible

## Set up Ansible Server

## Setup

```sh
export ANSIBLE_ROLES_PATH="${PWD}/roles" # from Ansible directory
ansible-galaxy install -r collections/requirements.yml --ignore-errors
sudo apt install -y ansible sshpass
if [ ! -d "/etc/ansible" ]; then
  sudo mkdir /etc/ansible
fi
sudo cp ansible.cfg hosts /etc/ansible
```

```fish
# for FISH shell, skip the "env" for BASH
env ANSIBLE_CONFIG=/etc/ansible/ansible.cfg ansible-galaxy install -r requirements.yml
env ANSIBLE_CONFIG=/etc/ansible/ansible.cfg ansible-galaxy collection install paloaltonetworks.panos
```

## AUTHENTICATION

Use Kerberos auth with my own user instead of "pi" user.

```bash
ssh-agent bash
ssh-add ~/.ssh/id_rsa
kinit -f franklin # generate a forwardable ticket
```

## Operation

```sh
ansible -i ./hosts -b --list-hosts nodes
ansible nodes -m ping -b -i ./hosts
ansible all -m setup -a "filter=ansible_distribution*" -i /home/franklin/workspace/LAB/lab-home/ansible/hosts # check dists
```

## Example Commands

```sh
ansible raspi_nodes -a 'apt update' -b -i ./hosts
ansible raspi_nodes -a 'apt -y upgrade' -b -i ./hosts
ansible-playbook playbook/playbook.yml -i ./hosts -b 
```

## Palo Alto Firewall

[Examples](https://github.com/PaloAltoNetworks/ansible-pan/tree/master/examples)

```sh
ansible-playbook -i firewalls playbook/firewalls.yml --ask-vault-pass -e 'ansible_python_interpreter=/usr/bin/python3'
```

## Managing Roles

Create a new Role:

```sh
molecule init role acme.my_new_role --driver-name docker
```
