# mpicc

```sh
apt-get update
apt-get -y install openssh-server git \
  htop python3-pip mpich mpi-default-dev libopenmpi-dev
```

* install jtop

```sh
pip3 install jetson_stats mpi4py
```

* test mpi

```sh
cd ~/clusterfs/mpi-cluster/
mpicc -showme
mpicc -o hello_mpi hello_mpi.c
mpiexec hello_mpi --hostfile /home/franklin/clusterfs/mpi-cluster/cluster
```

* python build

```sh
cd /mnt/clusterfs/TOOLS/Python-3.9.0
./configure --enable-optimizations --prefix=/mnt/clusterfs/nvidia/usr --with-ensurepip=install
# need a newer version of make on nvidia (4.1)
mpirun --hostfile /home/franklin/clusterfs/mpi-cluster/cluster -np 16 /mnt/clusterfs/TOOLS/make-4.3/make -j 16
```
