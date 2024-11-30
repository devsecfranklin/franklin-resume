# Tensorflow setup

```sh
ERROR: pip's dependency resolver does not currently take into account all the packages that are installed. This behaviour is the source of the following dependency conflicts.
tensorflow 2.5.0+nv21.8 requires gast==0.4.0, but you have gast 0.2.2 which is incompatible.
tensorflow 2.5.0+nv21.8 requires tensorboard~=2.5, but you have tensorboard 1.14.0 which is incompatible.
tensorflow 2.5.0+nv21.8 requires tensorflow-estimator<2.6.0,>=2.5.0rc0, but you have tensorflow-estimator 1.14.0 which is incompatible.
Successfully installed astor-0.8.1 gast-0.2.2 tensorboard-1.14.0 tensorflow-estimator-1.14.0 tensorflow-gpu-1.14.0+nv19.10
(_build) franklin@node900:~/clusterfs $ pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v42 tensorflow-gpu
```

```sh
sudo apt-get install python3-pip libhdf5-serial-dev hdf5-tools
pip3 install — pre — extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v42 tensorflow-gpu
```
