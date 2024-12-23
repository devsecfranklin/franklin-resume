# mpicc

* install

```sh
apt-get update
apt-get -y install openssh-server git htop python3-pip mpich mpi-default-dev libopenmpi-dev
```

* test

```sh
cd src/cluster_test
mpicc -dumpmachine
mpicc -showme
```

## OpenBSD

```sh
doas pkg_add openmpi
```

## Nvidia Jetson

* install jtop

```sh
pip3 install jetson_stats mpi4py
```

## test mpi

```sh
#mpicc -o hello_mpi hello_mpi.c
make DEBUG=[0:1]
mpiexec hello_mpi --hostfile /home/franklin/clusterfs/mpi-cluster/cluster
```

## python build

```sh
cd /mnt/clusterfs/TOOLS/Python-3.9.0
./configure --enable-optimizations --prefix=/mnt/clusterfs/nvidia/usr --with-ensurepip=install
# need a newer version of make on nvidia (4.1)
mpirun --hostfile /home/franklin/clusterfs/mpi-cluster/cluster -np 16 /mnt/clusterfs/TOOLS/make-4.3/make -j 16
```

## QEMU Builds

`https://azeria-labs.com/arm-on-x86-qemu-user/`
