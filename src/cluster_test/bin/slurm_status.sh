#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

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
