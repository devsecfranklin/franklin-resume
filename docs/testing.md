# Testing

* Install nix-shell

```sh
sudo install -d -m755 -o $(id -u) -g $(id -g) /nix
curl -L https://nixos.org/nix/install | sh
```

## Tox & Pytest

Create Docker Instance to Log in and Run `pytest`

* You must have Docker installed and running locally.
* Type `make build` to build the container.

```sh
source $HOME/.nix-profile/etc/profile.d/nix.sh
unset NIX_REMOTE || set -e NIX_REMOTE && if [ -f "gcp_tagging/requirements.txt" ]; then nix-shell; fi
python3 -m pip install tox
tox
exit
nix-collect-garbage -d
```
