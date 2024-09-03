# README.md

```sh
nix-env -i doctl -f https://github.com/NixOS/nixpkgs/archive/7138a338b58713e0dea22ddab6a6785abec7376a.tar.gz
unset NIX_REMOTE || set -e NIX_REMOTE
```

```sh
gpg --list-keys # get your public key id
pass init C25565E4701F4ED36A0711AA114F3606EFD923BB # id of your public GPG key
pass insert DO_TOKEN
pass ls
pass show
```

* Create Terraform plan.

```bash
export DO_TOKEN=$(pass DO_TOKEN) || export DO_TOKEN=(pass DO_TOKEN)
#terraform plan -out franklin.plan -var="do_token=${DO_TOKEN}" # BASH
terraform plan -out franklin.plan -var="do_token=$DO_TOKEN" # FISH
terraform show -json franklin.plan > tfplan.json
```

* Import existing

```sh
doctl account get
doctl auth init
export DO_TOKEN=$(pass DO_TOKEN) || export DO_TOKEN=(pass DO_TOKEN)
doctl compute domain records list bitsmasher.net
terraform import -var "do_token=${DO_TOKEN}" digitalocean_domain.default bitsmasher.net
terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.www bitsmasher.net,131134899
terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.txt1 bitsmasher.net,33037444
terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.mx bitsmasher.net,36318030
terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.txt2 bitsmasher.net,33037448
terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.dkim bitsmasher.net,33037446
terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.txt3 bitsmasher.net,33037450
terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.ns1 bitsmasher.net,33037438
terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.ns2 bitsmasher.net,33037439
terraform import -var "do_token=${DO_TOKEN}" digitalocean_record.ns3 bitsmasher.net,33037441
```
