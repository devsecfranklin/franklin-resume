# Terraform

## Google Cloud

```sh
gcloud components install kubectl
gcloud container clusters update ps-devsecops-gke --region us-central1 --enable-master-authorized-networks \
       --master-authorized-networks 156.146.51.68/32
gcloud auth application-default login
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
