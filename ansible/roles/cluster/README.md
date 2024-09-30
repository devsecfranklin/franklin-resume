# Cluster Playbook

Common files and stuff for all architectures.

## Depends On

* /mnt/clusterfs has to be mounted

## OpenMPI

```sh
wget https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.5.tar.bz2
```

## Auks

* [AUKS repo](https://github.com/cea-hpc/auks)

AUKS is a utility to add ease Kerberos V credential support to non-interactive
applications, like Slurm. It includes a plugin for the Slurm workload manager.

## Munge

* [install munge from here](https://dun.github.io/munge/)

## LBNL Node Health Check (NHC)

TORQUE, Slurm, and other schedulers/resource managers provide for a periodic
"node health check" to be performed on each compute node to verify that the node
is working properly. Nodes which are determined to be "unhealthy" can be marked
as down or offline so as to prevent jobs from being scheduled or run on them.
This helps increase the reliability and throughput of a cluster by reducing
preventable job failures due to misconfiguration, hardware failure, etc.

## References

* [building a raspberry pi cluster](https://medium.com/@glmdev/building-a-raspberry-pi-cluster-784f0df9afbd)
