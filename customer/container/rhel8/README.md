# Docker

* [Red Hat Universal Base Images for Docker users](https://developers.redhat.com/blog/2020/03/24/red-hat-universal-base-images-for-docker-users#introducing_red_hat_universal_base_images)
* [Enable snaps on Red Hat Enterprise Linux and install snapd](https://snapcraft.io/install/snapd/rhel)

## Install

* add the `RHEL_PASS` and `RHEL_USER` vars to the github action.
  * `pass show red-hat-container`

### Debian 12 Bookworm

* [Install Docker Engine on Debian](https://docs.docker.com/engine/install/debian/)

```sh
sudo groupadd docker
sudo usermod -aG docker $USER
sudo apt-get update && sudo apt-get install -y docker-compose-plugin # not found on popOS
sudo chmod a+rw /var/run/docker.sock
export DOCKER_CONFIG="/usr/libexec/docker"
sudo chgrp docker /usr/libexec/docker/
sudo chmod g+w /usr/libexec/docker
#export DOCKER_CONFIG="~/.docker/cli-plugins"
chmod +x ${DOCKER_CONFIG}/cli-plugins/docker-compose
```

Verify:

```sh
newgrp docker
docker compose version
docker run hello-world
```

## Build dev container

With `docker-compose`

```sh
sudo sysctl -w net.ipv6.conf.all.forwarding=1 # Use when you have IPv6 network issues
export CR_PAT=$(pass show ghcr)
echo $CR_PAT | docker login ghcr.io -u devsecfranklin --password-stdin
docker compose build customer-build || docker build -t ghcr.io/devsecfranklin/customer-build .
```

Without `docker-compose`

```sh
docker build -t ghcr.io/devsecfranklin/customer-build .
```

* Shell on the container

```sh
docker run -it ghcr.io/devsecfranklin/customer-build:latest bash
```
