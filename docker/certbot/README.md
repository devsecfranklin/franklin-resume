# Certbot

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