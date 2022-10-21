# CTFd Scoreboard in GKE

```sh
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
```

## Ingress LB

```sh
gcloud compute addresses list | grep devsecops 
gcloud compute addresses create web-ctfd-ip --global
gcloud compute addresses list | grep ctfd

k get ingress -n ctfd
```
