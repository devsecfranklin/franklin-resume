# README.md

- [Install `doctl`](https://docs.digitalocean.com/reference/doctl/how-to/install/)

## direnv

- install direnv

```sh
sudo apt-get -y install direnv
```

## pass

- install pass
- save your DIGITALOCEAN_TOKEN to your keyring

```sh
sudo apt-get -y install pass
gpg --list-keys # get your public key id
pass init C25565E4701F4ED36A0711AA114F3606EFD923BB # id of your public GPG key
pass insert DIGITALOCEAN_TOKEN
pass ls
pass show
```

## raspi setup

- install doctl
- initialize doctl

```sh
cd /tmp && wget https://github.com/digitalocean/doctl/releases/download/v1.147.0/doctl-1.147.0-linux-arm64.tar.gz
tar -xf /tmp/https://github.com/digitalocean/doctl/releases/download/v1.147.0/doctl-1.147.0-linux-arm64.tar.gz
sudo mv /tmp/doctl /usr/local/bin
export DIGITALOCEAN_TOKEN=$(pass DIGITALOCEAN_TOKEN) || export DIGITALOCEAN_TOKEN=(pass DIGITALOCEAN_TOKEN)
doctl auth init
doctl account get
```

## Terraform

- Create Terraform plan.

```sh
export DIGITALOCEAN_TOKEN=$(pass DIGITALOCEAN_TOKEN) || export DIGITALOCEAN_TOKEN=(pass DIGITALOCEAN_TOKEN)
terraform plan -out franklin.plan -var="DIGITALOCEAN_TOKEN=${DIGITALOCEAN_TOKEN}" # BASH
#terraform plan -out franklin.plan -var="DIGITALOCEAN_TOKEN=$DIGITALOCEAN_TOKEN" # FISH
terraform show -json franklin.plan > tfplan.json
```

- Import existing

```sh
doctl account get
doctl auth init
export DIGITALOCEAN_TOKEN=$(pass DIGITALOCEAN_TOKEN) || export DIGITALOCEAN_TOKEN=(pass DIGITALOCEAN_TOKEN)
doctl compute domain records list bitsmasher.net 
terraform import -var "DIGITALOCEAN_TOKEN=${DIGITALOCEAN_TOKEN}" digitalocean_domain.default bitsmasher.net
terraform import -var "DIGITALOCEAN_TOKEN=${DIGITALOCEAN_TOKEN}" digitalocean_record.www bitsmasher.net,131134899
terraform import -var "DIGITALOCEAN_TOKEN=${DIGITALOCEAN_TOKEN}" digitalocean_record.txt1 bitsmasher.net,33037444
terraform import -var "DIGITALOCEAN_TOKEN=${DIGITALOCEAN_TOKEN}" digitalocean_record.mx bitsmasher.net,36318030
terraform import -var "DIGITALOCEAN_TOKEN=${DIGITALOCEAN_TOKEN}" digitalocean_record.txt2 bitsmasher.net,33037448
terraform import -var "DIGITALOCEAN_TOKEN=${DIGITALOCEAN_TOKEN}" digitalocean_record.dkim bitsmasher.net,33037446
terraform import -var "DIGITALOCEAN_TOKEN=${DIGITALOCEAN_TOKEN}" digitalocean_record.txt3 bitsmasher.net,33037450
terraform import -var "DIGITALOCEAN_TOKEN=${DIGITALOCEAN_TOKEN}" digitalocean_record.ns1 bitsmasher.net,33037438
terraform import -var "DIGITALOCEAN_TOKEN=${DIGITALOCEAN_TOKEN}" digitalocean_record.ns2 bitsmasher.net,33037439
terraform import -var "DIGITALOCEAN_TOKEN=${DIGITALOCEAN_TOKEN}" digitalocean_record.ns3 bitsmasher.net,33037441
```

## metrics agent

```sh
curl -sSL https://repos.insights.digitalocean.com/install.sh | sudo bash
ps aux | grep do-agent # verify it is running
```

## nix

```sh
nix-env -i doctl -f https://github.com/NixOS/nixpkgs/archive/7138a338b58713e0dea22ddab6a6785abec7376a.tar.gz
unset NIX_REMOTE || set -e NIX_REMOTE
```
