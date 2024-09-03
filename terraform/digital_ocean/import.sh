#!/usr/bin/bash

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