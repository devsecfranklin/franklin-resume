# CN Series Stateful

- We are deploying CN series as a service.
- Old code: D5047944
- new dep profile: D9718286

- [CN-Series Prerequisites](https://docs.paloaltonetworks.com/cn-series/10-2/cn-series-deployment/secure-kubernetes-workloads-with-cn-series/cn-series-prerequisites)
- [CN-Series Performance and Scaling](https://docs.paloaltonetworks.com/cn-series/10-2/cn-series-deployment/cn-series-firewall-for-kubernetes/cn-series-performance-and-scalability#idcbe72b25-f36b-4fc1-af30-108a324a387b)

## Label

```sh
kubectl label node gke-ps-devsecops-gke-ps-east-cn-serie-a2a0d164-t4ey node-role.kubernetes.io/dev-test="cn-series"
kubectl label node gke-ps-devsecops-gke-ps-east-cn-serie-b8180b92-zyab node-role.kubernetes.io/dev-test="cn-series"
```

## Deploy

1. [Install the Kubernetes Plugin and Set up Panorama for CN-Series](https://docs.paloaltonetworks.com/cn-series/10-2/cn-series-deployment/secure-kubernetes-workloads-with-cn-series/install-the-kubernetes-plugin-for-cn-series)
2. [Deploy the CN-Series Firewall as a Kubernetes Service](https://docs.paloaltonetworks.com/cn-series/10-1/cn-series-deployment/secure-kubernetes-workloads-with-cn-series/deploy-the-cn-series-firewalls/deploy-the-cn-series-firewall-as-a-service)
3. [CN-Series Next-Generation Firewall Deployment](https://github.com/PaloAltoNetworks/Kubernetes)
4. [Editable Parameters in CN-Series Deployment YAML Files](https://docs.paloaltonetworks.com/cn-series/10-2/cn-series-deployment/secure-kubernetes-workloads-with-cn-series/editable-parameters-in-cn-series-deployment-yaml-files#id541ba06f-5cb8-4b79-a1c9-d8e5462ae9ba)
5. [Create Service Accounts for Cluster Authentication](https://docs.paloaltonetworks.com/cn-series/10-2/cn-series-deployment/secure-kubernetes-workloads-with-cn-series/create-service-accounts-for-cluster-authentication-with-cn-series)

```sh
kubectl apply -f pan-cni-configmap.yaml
kubectl apply -f pan-cn-mgmt-configmap.yaml
kubectl apply -f pan-cn-mgmt-secret.yaml
kubectl apply -f pan-cn-mgmt-0.yaml
kubectl apply -f pan-cn-mgmt-1.yaml
```

Put the `~/.kube/config` in as the cluster credentials in Panorama.

```sh
kubectl -n pa-cn get secrets pan-plugin-user-secret -o json >> gke-token.json
```

## Validate

```sh
k get pods -n pa-cn -l paloalto
kubectl get pods -l app=pan-mgmt -n pa-cn
```
