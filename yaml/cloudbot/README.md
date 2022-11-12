# Cloudbot

* Namespace is `ci-build`
* Set the image name in the repica set YAML to match the gcr.io image name.

```sh
kubectl config set-context --current --namespace=ci-build
kubectl apply -f replica-set.yaml
```

* Cloudbot service load balancer IP: `10.11.0.109:80`
