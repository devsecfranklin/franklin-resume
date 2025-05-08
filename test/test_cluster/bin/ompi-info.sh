#!/usr/bin/env bash

set -euxo pipefail

# Make a directory for the output files
mkdir -p "$(pwd)/ompi-output"

# Get installation and system information
ompi_info --all 2>&1       | tee $dir/ompi-info-all.out
lstopo -v                  | tee $dir/lstopo-v.txt
lstopo --of xml            | tee $dir/lstopo.xml

# Have a text file "my_hostfile.txt" containing the hostnames on
# which you are trying to launch
for host in $(cat my_hostfile.txt); do
    ssh $host ompi_info --version 2>&1 | tee $dir/ompi_info-version-$host.out
    ssh $host lstopo -v                | tee $dir/lstopo-v-$host.txt
    ssh $host lstopo --of xml          | tee $dir/lstopo-$host.xml
done

# Have a my_hostfile.txt file if needed for your environment, or
# remove the --hostfile argument altogether if not needed.
set +e
mpirun \
     --hostfile my_hostfile.txt \
     --map-by ppr:1:node \
     --prtemca plm_base_verbose 100 \
     --prtemca rmaps_base_verbose 100 \
     --display alloc \
     hostname 2>&1                     | tee $dir/mpirun-hostname.out

# Bundle up all of these files into a tarball
filename="ompi-output.tar.bz2"
tar -jcf $filename `basename $dir`
echo "Tarball $filename created"