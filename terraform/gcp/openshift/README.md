# OpenShift - OKD

## Set up the host Instance

* Check for Ubuntu images like so `gcloud compute images list --filter 'family ~ ubuntu'`
* `gcloud compute ssh --zone=europe-west2-a openshift-franklin`

## Install OKD

[Install OKD](https://www.okd.io/installation/)

```sh
terraform validate -json
terraform plan -out franklin.plan
```
