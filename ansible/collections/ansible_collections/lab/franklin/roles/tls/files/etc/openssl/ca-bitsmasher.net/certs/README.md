# certs

Once you run `bootstrap.sh` from `/etc/openssl` you cd in here and run `generate.sh`

## JSON

In a certificate used for a webserver, you would set the primary domain as the CN,
while you would add a hosts property (an array) with any alternative names (SAN) to
make sure that the certificate is bound to the specific domains only. But in the case
of a CA, we rather want a generic name than a domain.
