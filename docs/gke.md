# GKE Notes

## Setup

```sh
gcloud components install gke-gcloud-auth-plugin || sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
gke-gcloud-auth-plugin --version
gcloud components update
```

## Label Nodes

```sh
k get nodes
kubectl label node gke-ps-devsecops-gke-build-pool-0ccb2515-yshf node-role.kubernetes.io/build="build"
kubectl label node gke-ps-devsecops-gke-dev-test-6959817f-3oo1  node-role.kubernetes.io/dev-test="dev-test"
```

- Select node like so:

```yaml
      nodeSelector:
        "node-role.kubernetes.io/dev-test": dev-test
```

## Troubleshooting

- Stuck in Pending

```sh
kubectl get pods --field-selector=status.phase=Pending
kubectl describe pod ctfd-5cdb8d88f5-j6cmv
kubectl get pv
kubectl describe pv pvc-0df2fc1b-37e0-4258-85e7-67393065dde0
```
