# NFS Server

* Create the backend disk
* The `pd-standard` has a default size of 500GB
* Manage this with Terraform

```sh
gcloud compute disks create --zone=us-central1-b nfs-disk --type=pd-standard
```

* Set up the YAML

```sh
k apply -f storage-namespace.yaml
kubectl create -f nfs-server-deployment.yaml -n storage 
kubectl create -f nfs-clusterip-service.yaml -n storage
k get svc -n storage
```

Now your nfs server pods are accessible either at the IP 10.172.1.22 (note yours from the service output)
or via its name nfs-server.default.svc.cluster.local. By default every service is addressable via
name <service-name> .<namespace>.svc.cluster.local

* Create a PersistentVolume backed by this NFS server.
* You can have as big PV as you want, just make sure you do not exceed the limit of the
  original disk that you created.
* We can create as may PV and PVC as we want backed by same NFS server as long as we are not exceeding
  the original disk size that is attached to the NFS server.
