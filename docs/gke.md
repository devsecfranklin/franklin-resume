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

## Access

- Add your IP as a /32 around line 132 in networks.tf
  - ONLY /32 are allowed, otherwise IT will contact us about a violation.
- Add your IP as a /32 cidr_block in main.tf
  - example:

```hcl
   cidr_blocks {
      cidr_block   = "84.207.227.14/32"
      display_name = "kuba-remote"
    }
```

## Operation

The dashboard is already installed, but here is how you could re-install it:

```sh
kubectl apply --filename https://github.com/tektoncd/dashboard/releases/latest/download/tekton-dashboard-release.yaml
```

Start the dashboard from your local machine like so:

```sh
kubectl --namespace tekton-pipelines port-forward svc/tekton-dashboard 9097:9097
```

Now you can [Navigate to the Dashboard](http://127.0.0.1:9097/#/pipelineruns) in your local browser.

![bugs](https://github.com/devsecfranklin/gke-cluster/blob/main/docs/images/draft2.jpg)

## Troubleshooting

- Stuck in Pending

```sh
kubectl get pods --field-selector=status.phase=Pending
kubectl describe pod ctfd-5cdb8d88f5-j6cmv
kubectl get pv
kubectl describe pv pvc-0df2fc1b-37e0-4258-85e7-67393065dde0
```
