# CN Series Stateful

* [CN-Series Prerequisites](https://docs.paloaltonetworks.com/cn-series/10-2/cn-series-deployment/secure-kubernetes-workloads-with-cn-series/cn-series-prerequisites)
* [Deploy the CN-Series Firewall as a Kubernetes Service](https://docs.paloaltonetworks.com/cn-series/10-1/cn-series-deployment/secure-kubernetes-workloads-with-cn-series/deploy-the-cn-series-firewalls/deploy-the-cn-series-firewall-as-a-service)
* [CN-Series Performance and Scaling](https://docs.paloaltonetworks.com/cn-series/10-2/cn-series-deployment/cn-series-firewall-for-kubernetes/cn-series-performance-and-scalability#idcbe72b25-f36b-4fc1-af30-108a324a387b)

## Deploy

[CN-Series Next-Generation Firewall Deployment](https://github.com/PaloAltoNetworks/Kubernetes)
[Editable Parameters in CN-Series Deployment YAML Files](https://docs.paloaltonetworks.com/cn-series/10-2/cn-series-deployment/secure-kubernetes-workloads-with-cn-series/editable-parameters-in-cn-series-deployment-yaml-files#id541ba06f-5cb8-4b79-a1c9-d8e5462ae9ba)

```sh
kubectl apply -f pan-cn-mgmt-configmap-0.yaml
kubectl apply -f pan-cn-mgmt-configmap-1.yaml
kubectl apply -f pan-cn-mgmt-secret.yaml
kubectl apply -f pan-cn-mgmt-0.yaml
kubectl apply -f pan-cn-mgmt-1.yaml
```
