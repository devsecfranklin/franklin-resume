# Security

- k8s Authentication and Authorization
  - every request (humans and pods) goes to the API on port 6443.  
- Understand k8s security primitives
  - use the [pod security policy controls](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) (optional but recommended admission controller)
  - if you enable this without any policy it will prevent and resources from being created in the cluster.
- Know how to [configure network policies](https://docs.projectcalico.org/security/kubernetes-network-policy).
  - You can set ingress and egress rules. 
  - Your CNI must support network policies.
  - Kanal from Calico can be used to tell which pods can communicate in the pod spec definition
- [Create and manage TLS certificates](https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/) for cluster components 


- [Work with Images Securely](https://kubernetes.io/docs/concepts/containers/images/)
  - Use official source for images
  - Use the latest images and update periodically to capture latest fixes.
  - Use images scanning tools to scan for CVE and common vulns.
  - Use private registries so you know where you stuff comes from.
  - Set image pull to "always" and use "latest" tag to make sure you get fresh stuff
- [Defining Security Contexts for Pods and Containers](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
  - Run a pod a specific user or group
- [Secure persistent key value store](https://kubernetes.io/docs/concepts/configuration/secret/)

```sh
kubectl create secret
kubectl get secrets
kubectl describe secrets
```
