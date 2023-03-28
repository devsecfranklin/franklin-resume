# Cloudbot

* Namespace is `ci-build`
* Set the image name in the repica set YAML to match the gcr.io image name.

```sh
kubectl config set-context --current --namespace=ci-build
kubectl apply -f replica-set.yaml
```

* Cloudbot service load balancer IP: `10.11.0.109:80`

## Debug

* You can view the logs in the GKE console under the Services section of the cluster.
  (This is faster than waiting on Cloud Function logs to update)

```sh
k rollout history deployment cloudbot-deployment -n ci-build 
k logs -f deployment/cloudbot-deployment -n ci-build
kubectl logs (kubectl get pods -n ci-build | grep cloudbot-build-pod | cut -f1 -d' ')  -n ci-build -f
```

## Tasks

* Clone the repo/PR
* If there is a Makefile, build from it.
