#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT


#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --partition=clusterfs
cd $SLURM_SUBMIT_DIR
echo "Hello, World!" >/tmp/helloworld.txt
