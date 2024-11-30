#!/bin/bash
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=1
#SBATCH --partition=clusterfs

cd $SLURM_SUBMIT_DIR
mpiexec -n 6 /mnt/clusterfs/usr/bin/python3 daten_verarbeiten.py
