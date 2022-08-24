# Global Protect Lab GCP

## Generate Certificates

## Prepare VPN Client

Find Windows images

`gcloud compute images list --filter 'family ~ windows'`

## Set up Load Balancer per Region

Show the instance groups:

```sh
 gcloud compute instance-groups list --zones us-east1-b
 gcloud compute instance-groups list --zones us-east1-c
 gcloud compute instance-groups list --zones us-central1-a
```
