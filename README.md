```sh
 _____                _    _ _         ____
|  ___| __ __ _ _ __ | | _| (_)_ __   |  _ \ ___  ___ _   _ _ __ ___   ___
| |_ | '__/ _` | '_ \| |/ / | | '_ \  | |_) / _ \/ __| | | | '_ ` _ \ / _ \
|  _|| | | (_| | | | |   <| | | | | | |  _ <  __/\__ \ |_| | | | | | |  __/
|_|  |_|  \__,_|_| |_|_|\_\_|_|_| |_| |_| \_\___||___/\__,_|_| |_| |_|\___|

```

[![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/devsecfranklin/franklin-resume/general)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=devsecfranklin%2Ffranklin-resume&benchmark=INFRASTRUCTURE+SECURITY) [![Coverage Status](https://coveralls.io/repos/github/theDevilsVoice/franklin-resume/badge.svg?branch=master)](https://coveralls.io/github/theDevilsVoice/franklin-resume?branch=master)

## View My Resume

* [Heroku Version](https://franklin-resume.herokuapp.com/) is running here. You probably want this.

## Container

* [Docker Hub: Latest Container Image](https://hub.docker.com/repository/docker/frank378/franklin-resume)

## Tox & Pytest w/Nix

* Install nix-shell

```sh
sudo install -d -m755 -o $(id -u) -g $(id -g) /nix
curl -L https://nixos.org/nix/install | sh
```

Create Docker Instance to Log in and Run `pytest`

* You must have Docker installed and running locally.
* Type `make build` to build the container.

```sh
source $HOME/.nix-profile/etc/profile.d/nix.sh
unset NIX_REMOTE || set -e NIX_REMOTE && if [ -f "requirements.txt" ]; then nix-shell; fi
python3 -m pip install tox
tox
exit
nix-collect-garbage -d
```
