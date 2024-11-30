# tensorflow

[from page](https://thenewstack.io/tutorial-deploying-tensorflow-models-at-the-edge-with-nvidia-jetson-nano-and-k3s/)
[l4t-tensor](https://www.hackster.io/WhoseAI/running-k3s-lightweight-kubernetes-on-nv-jetson-cluster-93e577)

```sh
sudo docker pull nvcr.io/nvidia/l4t-tensorflow:r32.4.3-tf2.2-py3
sudo docker run -it --rm --runtime nvidia --network host nvcr.io/nvidia/l4t-tensorflow:r32.4.3-tf2.2-py3 python3
```

```sh
import tensorflow as tf
print(tf.__version__)
tf.config.list_physical_devices('GPU')
```

```sh
kubectl apply -f tensorflow2.yaml
kubectl get pods --all-namespaces
kubectl exec -it tensorflow -- python3
```
