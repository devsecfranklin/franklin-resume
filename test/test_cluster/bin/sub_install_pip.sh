#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2024 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1

#/mnt/clusterfs/usr/bin/pip3 install numpy mpi4py
/mnt/clusterfs/usr/bin/pip3 install pyod
