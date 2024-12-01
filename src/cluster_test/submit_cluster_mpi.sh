#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2024 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# ChangeLog:
#
# v0.1 02/25/2022 Maintainer script
# v0.2 11/24/2024 Update this script

WORKDIR="$(pwd)"

#SBATCH --nodes=4
#SBATCH --ntasks-per-node=1
make

cd $SLURM_SUBMIT_DIR

# Print the node that starts the process
echo "Master node: $(hostname)"

# Run our program using OpenMPI.
# OpenMPI will automatically discover resources from SLURM.

#mpirun ${WORKDIR}/hello_mpi
#mpirun -n 2 ${WORKDIR}/prime_check
srun -l ${WORKDIR}/prime_check
