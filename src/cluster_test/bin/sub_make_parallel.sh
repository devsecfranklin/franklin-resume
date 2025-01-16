#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2024 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1        # cpu-cores per task
# #SBATCH --mem-per-cpu=1G         # memory per cpu-core
#SBATCH --time=00:05:00          # total run time limit (HH:MM:SS)

#cd $SLURM_SUBMIT_DIR

# Print the node that starts the process
echo "Main node: $(hostname)"

#srun /mnt/clusterfs/usr/bin/python3 cluster_python3_test.py
srun /mnt/clusterfs/build/make-4.3/make -j 10
