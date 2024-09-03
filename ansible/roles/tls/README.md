# SSL Setup

Use this continaer to add certbot certs to firewalls, etc.

* [A list of certbot DNS plugins can be found here](https://certbot.eff.org/docs/using.html#dns-plugins)

## Slow

* Build dev container

```sh
sudo sysctl -w net.ipv6.conf.all.forwarding=1 # Use when you have IPv6 network issues
export CR_PAT=$(pass show ghcr)
echo $CR_PAT | docker login ghcr.io -u devsecfranklin --password-stdin
docker build -t ghcr.io/devsecfranklin/certbot --build-arg PASS=123abcEFG .
```

```sh
# generate root CA private key
openssl genrsa -des3 -out /etc/ssl/private/server.key 2048
# generate the root cert
openssl req -x509 -new -nodes -key /etc/ssl/private/server.key -sha256 -days 1825 -out /etc/ssl/certs/lab.bitsmasher.net.pem
# generate host key
openssl genrsa -out head2.lab.bitsmasher.net.key 2048
# generate CSR
openssl req -new -key head2.lab.bitsmasher.net.key -out head2.lab.bitsmasher.net.csr
# verify CSR
openssl req -in head2.lab.bitsmasher.net.csr -noout -subject
# copy CSR to CA server
# echo "XXXXX" > mypass.txt
# openssl x509 -req -days 365 -in head2.lab.bitsmasher.net.csr -CA /etc/ssl/certs/lab.bitsmasher.net.pem \
# -CAkey /etc/ssl/private/server.key -CAcreateserial -out /etc/ssl/certs/head2.crt -passin file:mypass.txt
openssl req  -noout -text -in /etc/ssl/server.csr
openssl x509  -noout -text -in /etc/ssl/certs/server.crt
```
