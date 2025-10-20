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

## Setup Certificates

```sh
/usr/lib/ssl/misc/CA.pl -newca # use this file to set up CA
/usr/lib/ssl/misc/CA.pl -signCA
/usr/lib/ssl/misc/CA.pl -newreq # generate a CSR
/usr/lib/ssl/misc/CA.pl -sign
openssl rsa < newkey.pem > clearkey.pem # create an unencrypted version of the key file
cp /etc/ssl/demoCA/cacert.pem /etc/ldap/bitsmasher.net.cert.pem # copy the CA cert
cp /etc/ssl/clearkey.pem /etc/ldap/bitsmasher.net.key.pem # copy the CA key
```

## TLS Troubleshooting Client/Server Connections

* Ensure both client and server support at least TLS 1.2 (and preferably TLS 1.3).
  * Check your browser's or application's TLS settings to enable TLS 1.2 or higher.
* The SSL/TLS certificate might be expired, revoked, untrusted, or have a name mismatch
  * Verify the certificate's validity and ensure it's issued by a trusted Certificate Authority (CA).
  * Check for any errors or warnings related to the certificate in your browser or application.
  * If using a self-signed certificate, ensure it's properly configured and trusted by the client.
* Ensure both client and server support a common set of cipher suites.
  * Check the server's configuration to see which cipher suites are enabled.

### Palo Alto Networks

* [Configure an SSL/TLS Service Profile (PAN-OS & Panorama)](https://docs.paloaltonetworks.com/pan-os/11-1/pan-os-admin/certificate-management/configure-an-ssltls-service-profile/configure-an-ssltls-service-profile-pan-os)
* [How to detect the SSL or TLS version being used](https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA14u0000008UgRCAU)
