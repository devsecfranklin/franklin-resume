# Cloudbot Container image

* The name `build-pod` will be used in the YAML for the replica set.

```sh
sudo sysctl -w net.ipv6.conf.all.forwarding=1
docker build -t gcr.io/gcp-gcs-pso/build-pod .
docker push gcr.io/gcp-gcs-pso/build-pod
```
