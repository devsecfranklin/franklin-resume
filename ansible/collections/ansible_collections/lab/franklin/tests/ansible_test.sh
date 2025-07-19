#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# ChangeLog:
#
# v0.1 10/19/2024 initial version

# check if ANSIBLE_HOME +ANSIBLE_LOCAL_TEMP +ANSIBLE_REMOTE_TEMP +ANSIBLE_ROLES_PATH  is set

# check for /var/log/ansible or create it

# check for /etc/ansible/hosts otherwise copy it in

ansible-config -v dump >/tmp/ansible.cfg

## Testing
# [Getting Started With Molecule](https://ansible.readthedocs.io/projects/molecule/getting-started/)

# ```sh
# cd ansible/collections/ansible_collections/lab/franklin/roles/cluster
# mkdir extensions && cd extensions
# molecule init scenario # creates the default dir
# molecule test # The full test lifecycle sequence
# molecule converge # runs the same steps as molecule test for the default scenario, but will stop after the converge action.
# ```

### Test Files

# * `create.yml` is a playbook file used for creating the instances and storing data in instance-config
# * `destroy.yml` has the Ansible code for destroying the instances and removing them from instance-config
# * `molecule.yml` is the central configuration entry point for Molecule per scenario. With this file,
# you can configure each tool that Molecule will employ when testing your role.
# * `converge.yml` is the playbook file that contains the call for your role. Molecule will invoke
# this playbook with ansible-playbook and run it against an instance created by the driver.

# add the molecule files to the role
MOLECULE_SRC_FILES_DIR="/home/franklin/workspace/LAB/lab-franklin/ansible/collections/ansible_collections/lab/franklin/extensions/molecule/default"
declare -a MOLECULE_FILES=("collections.yml" "create.yml" "destroy.yml" "molecule.yml")
function add_test_harness() {
  for i in "${MOLECULE_FILES[@]}"; do
    cp ${MOLECULE_SRC_FILES_DIR}/${i} molecule/default
  done
}
