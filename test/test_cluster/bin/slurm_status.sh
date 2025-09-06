#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT


# systemctl is-enabled munge
# systemctl is-enabled slurmd
# systemctl status slurmctld # on the head node only

sinfo -s
#srun --mpi=list
#scontrol show node node[0-3]

# this will fix the node unexpetedly rebooted error
#sudo -i scontrol update state=resume NodeName=node

# run a command on all nodes
# ansible raspi_nodes -a 'whoami' -b -i /etc/ansible/hosts
