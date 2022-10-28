# Terraform

## Google Cloud

```sh
gcloud components install kubectl
gcloud container clusters get-credentials --region us-central1 ps-devsecops-gke
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
gcloud container clusters update pso-automation-fdiaz-gke --region us-central1 --enable-master-authorized-networks  --master-authorized-networks 104
.196.60.8/32
```
