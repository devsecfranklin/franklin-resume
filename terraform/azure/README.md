# Test Infra

Backend hosts for traffic testing

## deploy

```sh
az login --scope https://graph.microsoft.com/.default
az vm image terms accept --publisher paloaltonetworks --offer vmseries-flex --plan byol 
az vm image accept-terms --offer vmseries-flex --publish paloaltonetworks --plan bundle2
```

## Global Protect

Add GP setup directions here
