# measure twice, cut once

About the testing.

* Add a "password =" line to config.ini
  * It needs to match what you set for the XML user on the Panorama.
* type `make test` from the top level of the repo.
* Test cases run in `nix-shell`. So you have to install `nix-shell`.
* Cloud function needs private IP. Test cases need public IP and maybe disable GP.

## Python Local Dev Env (Single User Nix Shell install)

To install Nix from any Linux distribution, use the following two commands.
(Note: This assumes you have the permission to use `sudo`, and you are logged
in as the user you want to install Nix for.)

Starting with macOS 10.15 (Catalina), the root filesystem is read-only.
This means `/nix` can no longer live on your system volume, and that you'll
need a workaround to install Nix.

You can read more about this topic in the Nix
[documentation](https://nixos.org/manual/nix/stable/#sect-macos-installation).

* Install nix-shell

```sh
sudo install -d -m755 -o $(id -u) -g $(id -g) /nix
curl -L https://nixos.org/nix/install | sh
```

Now you are ready to rock. Type `make test` or do things the old fashioned way:

```sh
source $HOME/.nix-profile/etc/profile.d/nix.sh
# from top level of repo
unset NIX_REMOTE || set -e NIX_REMOTE && if [ -f "gcp_tagging/requirements.txt"
 ]; then nix-shell; fi
python3 -m pip install tox
tox
exit
nix-collect-garbage -d
```

