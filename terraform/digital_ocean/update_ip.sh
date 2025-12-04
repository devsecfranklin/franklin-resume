PUBLIC_IP=`wget http://ipecho.net/plain -O - -q ; echo`
echo "my ip: $PUBLIC_IP"

# now update the dns.tf file with sed

# terraform plan -out franklin.plan -target digitalocean_record.research

