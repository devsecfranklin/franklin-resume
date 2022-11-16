# Cloudbot Container image

## Build application

```sh
npm install winston
npm install octokit
pass show GIT_TOKEN
```

## Build Container and push to gcr

* The name `build-pod` will be used in the YAML for the replica set.

```sh
sudo sysctl -w net.ipv6.conf.all.forwarding=1
docker build -t gcr.io/gcp-gcs-pso/build-pod .
docker push gcr.io/gcp-gcs-pso/build-pod
docker history --human --format "{{.CreatedBy}}: {{.Size}}" gcr.io/gcp-gcs-pso/build-pod
```

## Debug

```sh
k rollout history deployment cloudbot-deployment -n ci-build 
k logs -f deployment/cloudbot-deployment -n ci-build
kubectl logs (kubectl get pods -n ci-build | grep cloudbot-build-pod | cut -f1 -d' ')  -n ci-build -f
```
