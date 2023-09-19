# Lab Backend

- lab-franklin-windows
- ps-devsecops-fw01
- "10.252.0.0/25" mgmt

## Jump Box

```sh
gcloud compute ssh --zone=us-central1-a lab-franklin-airlock1
```

## Mac Terraform Setup

```sh
brew install kreuzwerker/taps/m1-terraform-provider-helper
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
m1-terraform-provider-helper activate
m1-terraform-provider-helper install hashicorp/template -v v2.2.0
terraform providers lock -provider=darwin_arm64
```

## Subnets/CIDR Blocks

| Name | CIDR |
| ---- | ---- |
| lab-franklin-gp-client-subnet | 10.10.24.0/24 |
| lpgcen-ppal-mgmt | 10.252.0.0/24 |
| lpgcen-ppal-ingress | 10.252.1.0/24 |
| lpgcen-ppal-egress | 10.252.2.0/24 |
| ps-devsecops-mgmt | 192.168.0.0 |
| ps-devsecops-untrust | 192.168.1.0 |
| ps-devsecops-trust | 192.168.2.0 |

## Terraform

```sh
brew install kreuzwerker/taps/m1-terraform-provider-helper
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
m1-terraform-provider-helper activate
m1-terraform-provider-helper install hashicorp/template -v v2.2.0
```

Import existing:

```sh
terraform import google_storage_bucket.terraform_state franklin-gcp-terraform
terraform import google_compute_network.vpc projects/gcp-gcs-pso/global/networks/franklin-lab-mgmt-vpc
terraform import google_compute_firewall.lab-ingress projects/gcp-gcs-pso/global/firewalls/franklin-lab-ingress
```

## Eve NG Virtualization

- [Use the Community cookbook](https://www.eve-ng.net/index.php/documentation/community-cookbook/)

## Find Windows images

`gcloud compute images list --filter 'family ~ windows'`

## OpenShift - OKD

### Set up the host Instance

- Check for Ubuntu images like so `gcloud compute images list --filter 'family ~ ubuntu'`
- `gcloud compute ssh --zone=europe-west2-a openshift-franklin`

### Install OKD

[Install OKD](https://www.okd.io/installation/)

```sh
terraform validate -json
terraform plan -out franklin.plan
```

## GKE Cluster

```sh
gcloud container clusters get-credentials lab-franklin-gke --region=us-central1
```

Test Cloudflare API token

```sh
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer XXXYYYZZZ" \
     -H "Content-Type:application/json"
```

## CTFd Scoreboard in GKE

High availablity deployment of CTFd on Kubernetes.

### Setup

variables can be added easily with a .tfvars file. See terraform.tfvars

```sh
gcloud config set project europe-north1
```

Create Google Cloud Storage Bucket for Terraform State

```sh
export TERRAFORM_STATE_GCP_BUCKET=europe-north1-tf-state
gsutil mb -b on -c standard -l europe-north1 gs://TERRAFORM_STATE_GCP_BUCKET
```

Create Terraform Service Account

```sh
gcloud iam service-accounts create terraform
gcloud iam service-accounts keys create \
  --iam-account terraform@$PROJECT.iam.gserviceaccount.com \
  PROJECT.json
gcloud projects add-iam-policy-binding PROJECT \
  --member serviceAccount:terraform@PROJECT.iam.gserviceaccount.com \
  --role roles/editor
```

Create Terraform Encryption Key

```sh
export GOOGLE_ENCRYPTION_KEY=$(openssl rand -base64 32)
export GOOGLE_APPLICATION_CREDENTIALS=PROJECT.json
export GOOGLE_CREDENTIALS=$(cat $GOOGLE_APPLICATION_CREDENTIALS | tr -d '\n')
```

### terraform.tfvars

```sh
cert_manager_enabled        = "false"
cloudflare_api_token        = ""
cloudflare_email            = ""
cloudflare_zone_id          = ""
cluster_name                = ""
domain                      = ""
google_project              = ""
google_region               = ""
google_zone                 = ""
grafana_password            = ""
kong_enabled                = true
node_pool_name              = ""
prometheus_blackbox_enabled = false
prometheus_blackbox_targets = ""
storage_bucket              = ""
```
