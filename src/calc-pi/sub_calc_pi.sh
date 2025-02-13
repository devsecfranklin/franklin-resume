#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2024 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

#SBATCH --ntasks=6

cd $SLURM_SUBMIT_DIR

mpiexec -n 6 /mnt/clusterfs/usr/bin/python3 calculate.py
