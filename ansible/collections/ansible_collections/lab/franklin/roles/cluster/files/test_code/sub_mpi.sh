#!/bin/bash
#SBATCH --ntasks=8

cd $SLURM_SUBMIT_DIR

# Print the node that starts the process
echo "Master node: $(hostname)"

# Run our program using OpenMPI.
# OpenMPI will automatically discover resources from SLURM.
mpirun /mnt/storage1/LAB/src/hello_world_slurm/hello_mpi
