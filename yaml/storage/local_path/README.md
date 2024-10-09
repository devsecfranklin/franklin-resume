# Local Path Storage

```sh
kubectl create -f pvc-local-path.yml
kubectl create -f local-path-pod-ex.yaml
kubectl get pods -o wide -n storage
```

The pod only has one container, so we can get a shell to the container with the following command:

```sh
kubectl exec -it local-path-test -- sh
```

PVC should show up on local filesystem

```sh
/var/lib/rancher/k3s/storage/
```
