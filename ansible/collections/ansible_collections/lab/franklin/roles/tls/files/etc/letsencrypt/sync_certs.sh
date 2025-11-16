# from wonderland
certbot -d packetlord.gcp.bitsmasher.net --manual  --preferred-challenges dns certonly

# from chonk
scp -rp wonderland:/etc/letsencrypt/archive .

