#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --partition=clusterfs
cd $SLURM_SUBMIT_DIR
echo "Hello, World!" > /tmp/helloworld.txt
