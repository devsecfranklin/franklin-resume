# Terraform

* [CN-Series Prerequisites](https://docs.paloaltonetworks.com/cn-series/10-2/cn-series-deployment/secure-kubernetes-workloads-with-cn-series/cn-series-prerequisites)
* [Deploy the CN-Series Firewall as a Kubernetes Service](https://docs.paloaltonetworks.com/cn-series/10-1/cn-series-deployment/secure-kubernetes-workloads-with-cn-series/deploy-the-cn-series-firewalls/deploy-the-cn-series-firewall-as-a-service)
* [CN-Series Performance and Scaling](https://docs.paloaltonetworks.com/cn-series/10-2/cn-series-deployment/cn-series-firewall-for-kubernetes/cn-series-performance-and-scalability#idcbe72b25-f36b-4fc1-af30-108a324a387b)

## Google Cloud

```sh
gcloud components install kubectl
gcloud container clusters update ps-devsecops-gke --region us-central1 --enable-master-authorized-networks \
       --master-authorized-networks 156.146.51.68/32
gcloud auth application-default login
gcloud container clusters update ps-devsecops-gke --project gcp-gcs-pso --zone 'us-central1' --enable-autoprovisioning \ --autoprovisioning-image-type='COS_CONTAINERD'
```

## Create Cluster

* Run Terraform to create the cluster.
* Scan your TF files before deploying and after updates.

```sh
terraform init -reconfigure
terraform plan -out franklin.plan -var-file=terraform.tfvars
tfsec --tfvars-file terraform.tfvars
terraform apply  "franklin.plan"
```

access from cloud shell

```sh
dig +short myip.opendns.com @resolver1.opendns.com
gcloud container clusters update pso-automation-fdiaz-gke --region us-central1 \
       --enable-master-authorized-networks  --master-authorized-networks 104.196.60.8/32
```

## Access

* Add your IP as a /32 around line 132 in networks.tf
  * ONLY /32 are allowed, otherwise IT will contact us about a violation.
* Add your IP as a /32 cidr_block in main.tf
  * example:

```hcl
   cidr_blocks {
      cidr_block   = "84.207.227.14/32"
      display_name = "kuba-remote"
    }
```
