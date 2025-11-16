#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v0.1 10/19/2024 initial version
# v0.2 11/11/2025 Updates

LRED='\033[1;31m'

TEST_DIR="/mnt/clusterfs2/workspace/lab-franklin/test"

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
MOLECULE_SRC_FILES_DIR="${TEST_DIR}/extensions/molecule/default"
declare -a MOLECULE_FILES=("collections.yml" "create.yml" "destroy.yml" "molecule.yml")


function add_test_harness() {
  log_header "add test harness"

  for i in "${MOLECULE_FILES[@]}"; do
    log_info "copy files into extensions/molecule/default"
    cp ${MOLECULE_SRC_FILES_DIR}/${i} "${MOLECULE_SRC_FILES_DIR}"
  done
}

function main() {
  figlet -f fonts/pagga workspace && echo -e "\n"
  if [ -f "../bin/common.sh" ]; then
    source "../bin/common.sh"
  else
    echo -e "${LRED}can not find common.sh.${NC}"
    exit 1
  fi
  log_info "successfully sourced common.sh" && echo -e "\n"

  add_test_harness
}

main "$@"
