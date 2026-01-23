# Cluster Maintenance

- [Cluster upgrade process](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)
  - Based on using kubeadm
  - Read the release notes, [have a backup of your cluster](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster), prepare thoroughly
  - upgrade kubeadm
  - Drain control plane node
  - sudo kubeadm upgrade plan
  - All containers will be restarted
  - kubectl uncordon
  - upgrade kubectl
  - sudo systemctl restart kubelet
  - upgrade worker nodes
- Operating system upgrades
  - drain
  - uncordon
- [Implement backup and restore methodologies](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster)
  - Master node with k8s configuration and etcd database
  - application images (usually in a registry) and any application data, which should be external to the image.
  - Two ways to backup etcd
    - etcd snapshot option
    - volume snapshot option
    