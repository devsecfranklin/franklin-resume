#((Assuming the baby new install of Ubuntu on the Jetson Nano)) 
#(MAKE SURE IT IS JETPACK 4.6.1!)

#Update your stuff.
sudo apt update && sudo apt upgrade
sudo apt install python3-pip python-pip
sudo reboot

#Install Aarch64 Conda
cd ~
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh .
chmod a+x Miniforge3-Linux-aarch64.sh
./Miniforge3-Linux-aarch64.sh
sudo reboot

#Install other python things.
sudo apt install python3-h5py libhdf5-serial-dev hdf5-tools libpng-dev libfreetype6-dev

#Create the Conda for llamacpp
conda create -n llamacpp
conda activate llamacpp

# build this repo
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
make

#Requires next, the torch. Pytorch is on Jetson Nano, lets install this!
#From NVIDIA we can learn here what to install PyTorch on our Nano.
#https://docs.nvidia.com/deeplearning/frameworks/install-pytorch-jetson-platform/index.html

#make Sure everything is update!
sudo apt-get -y update

#Install Prerequisite
sudo apt-get -y install autoconf bc build-essential g++-8 gcc-8 clang-8 lld-8 gettext-base gfortran-8 iputils-ping libbz2-dev libc++-dev libcgal-dev libffi-dev libfreetype6-dev libhdf5-dev libjpeg-dev liblzma-dev libncurses5-dev libncursesw5-dev libpng-dev libreadline-dev libssl-dev libsqlite3-dev libxml2-dev libxslt-dev locales moreutils openssl python-openssl rsync scons python3-pip libopenblas-dev;

#Make the Install path. This is for the JetPack 4.6.1
export TORCH_INSTALL=https://developer.download.nvidia.com/compute/redist/jp/v461/pytorch/torch-1.11.0a0+17540c5+nv22.01-cp36-cp36m-linux_aarch64.whl

#Run each individually!!! Make sure they work.
python3 -m pip install --upgrade pip 
python3 -m pip install aiohttp 
python3 -m pip install numpy=='1.19.4' 
python3 -m pip install scipy=='1.5.3' 
export "LD_LIBRARY_PATH=/usr/lib/llvm-8/lib:$LD_LIBRARY_PATH";

#LLaMa.cpp need this sentencepiece!
#We can learn how to build on nano from here! https://github.com/arijitx/jetson-nlp

git clone https://github.com/google/sentencepiece 
cd /path/to/sentencepiece 
mkdir build 
cd build 
cmake .. 
make -j $(nproc) 
sudo make install 
sudo ldconfig -v 
cd ..  
cd python 
python3 setup.py install

#Upgrade protobuf, and install the torch!
python3 -m pip install --upgrade protobuf; python3 -m pip install --no-cache $TORCH_INSTALL
#Check to make this works!
python3 -c "import torch; print(torch.cuda.is_available())"
#If respond true! Then it is ok!

