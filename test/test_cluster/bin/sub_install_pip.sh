#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT


#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1

#/mnt/clusterfs/usr/bin/pip3 install numpy mpi4py
/mnt/clusterfs/usr/bin/pip3 install pyod
