# CN Series Deployment

Deploy CN series as a Kubernetes CNF

## Prepare

* [Prepare the deployment](https://docs.paloaltonetworks.com/cn-series/10-2/cn-series-deployment/secure-kubernetes-workloads-with-cn-series#id9309f85f-e8c5-41ca-802a-0e29d5318fd3)
* [Create a deployment profile](https://docs.paloaltonetworks.com/cn-series/10-2/cn-series-deployment/license-the-cn-series-firewall/create-a-deployment-profile-cn-series)
  * `CN-FRANKLIN-CNF-TEST`
* [Get the image locations from GCR](https://docs.paloaltonetworks.com/cn-series/10-2/cn-series-deployment/secure-kubernetes-workloads-with-cn-series/get-the-images-and-files-for-the-cn-series-deployment)
* Create the Device Group and Template in Panorama.

## YAML

* CN-Series-as-a-kubernetes-CNF in HA supports only active/passive HA with session and configuration synchronization.
* When you deploy the CN-Series-as-a-kubernetes-CNF in HA, there will be two PAN-CN-MGMT-CONFIGMAP, PAN-CN-MGMT, and PAN-CN-NGFW YAML files each for active and passive node pair.
* [Follow these steps to get the YAML](https://github.com/PaloAltoNetworks/Kubernetes)
* [Edit the YAML files](https://docs.paloaltonetworks.com/cn-series/10-2/cn-series-deployment/secure-kubernetes-workloads-with-cn-series/editable-parameters-in-cn-series-deployment-yaml-files#id541ba06f-5cb8-4b79-a1c9-d8e5462ae9ba)

Deploy:

```sh
kubectl apply -f pan-cn-mgmt-configmap-0.yaml
kubectl apply -f pan-cn-mgmt-configmap-1.yaml
kubectl apply -f pan-cn-mgmt-secret.yaml
kubectl apply -f pan-cn-mgmt-0.yaml
kubectl apply -f pan-cn-mgmt-1.yaml
```
