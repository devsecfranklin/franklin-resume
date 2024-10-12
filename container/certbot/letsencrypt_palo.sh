#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <thedevilsvoice@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

CLOUDFLARE_CREDS=/app/.cloudflare.ini
PAN_MGMT=34.134.31.136
FQDN=panorama1.dead10c5.org
EMAIL=franklin@bitsmasher.net
API_KEY=$(cat /app/.panrc)
CERT_NAME=LetsEncryptPanorama
GP_PORTAL_TLS_PROFILE=GP_PORTAL_PROFILE
GP_GW_TLS_PROFILE=GP_EXT_GW_PROFILE
TEMP_PWD=$(openssl rand -hex 15)
#Requirements: openssl, pan-python, certbot

/usr/local/bin/certbot certonly --dns-cloudflare --dns-cloudflare-credentials $CLOUDFLARE_CREDS -d *.$FQDN -n --agree-tos --force-renew
#Depending on your setup, certbot may not give you separate files for the certificate and chain.  This script expects separate files.
openssl pkcs12 -export -out letsencrypt_pkcs12.pfx -inkey /etc/letsencrypt/live/$FQDN/privkey.pem -in /etc/letsencrypt/live/$FQDN/cert.pem -certfile /etc/letsencrypt/live/$FQDN/chain.pem -passout pass:$TEMP_PWD
curl -k --form file=@letsencrypt_pkcs12.pfx "https://$PAN_MGMT/api/?type=import&category=certificate&certificate-name=$CERT_NAME&format=pkcs12&passphrase=$TEMP_PWD&key=$API_KEY" && echo " "
curl -k --form file=@letsencrypt_pkcs12.pfx "https://$PAN_MGMT/api/?type=import&category=private-key&certificate-name=$CERT_NAME&format=pkcs12&passphrase=$TEMP_PWD&key=$API_KEY" && echo " "
sudo rm letsencrypt_pkcs12.pfx
#If you use a separate SSL/TLS Service Profile for the GlobalProtect Portal and Gateway, uncomment the next line and update the 'GP_PORTAL_TLS_PROFILE' variable with the name of your GlobalProtect Portal's SSL/TLS Service Profile, as it appears in your management GUI.
panxapi.py -h $PAN_MGMT -K $API_KEY -S "$CERT_NAME" "/config/shared/ssl-tls-service-profile/entry[@name='$GP_PORTAL_TLS_PROFILE']"
#If you use a separate SSL/TLS Service Profile for the GlobalProtect Portal and Gateway, uncomment the next line and update the 'GP_GW_TLS_PROFILE' variable with the name of your GlobalProtect Gateway's SSL/TLS Service Profile, as it appears in your management GUI. If you use a single SSL/TLS Service Profile for BOTH the Portal and Gateway, you can comment the following line out, or set the value of 'GP_GW_TLS_PROFILE' to the value of 'GP_PORTAL_TLS_PROFILE'
panxapi.py -h $PAN_MGMT -K $API_KEY -S "$CERT_NAME" "/config/shared/ssl-tls-service-profile/entry[@name='$GP_GW_TLS_PROFILE']"
panxapi.py -h $PAN_MGMT -K $API_KEY -C '' --sync
