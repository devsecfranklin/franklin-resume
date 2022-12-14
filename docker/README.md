# Docker

## Fast

```sh
make build
make latex
make push
```

## Slow

* Build dev container

```sh
sudo sysctl -w net.ipv6.conf.all.forwarding=1 # Use when you have IPv6 network issues
export CR_PAT=(pass show ghcr)
echo $CR_PAT | docker login ghcr.io -u devsecfranklin --password-stdin
docker-compose build franklin-resume || docker build -t ghcr.io/devsecfranklin/franklin-resume .
```

* Verify the container

```sh
docker inspect ghcr.io/devsecfranklin/franklin-resume
```

* Run the container

```sh
docker run -it ghcr.io/devsecfranklin/franklin-resume:latest bash
```
