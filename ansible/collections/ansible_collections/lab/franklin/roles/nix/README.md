Nix
===

```sh
sudo install -d -m755 -o $(id -u) -g $(id -g) /nix
curl -L https://nixos.org/nix/install | sh
```

Then don't forget to run the command provided at the end of the installation
script to make nix available in your system:

* BASH users (you probably want this)

```sh
source $HOME/.nix-profile/etc/profile.d/nix.sh
```

* For FISH users (you can probably skip this)

```sh
set -x NIX_PATH (echo $NIX_PATH:)nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs
```

Now you can use the virtual envrionment:

```sh
nix-shell
python -m pip install -rrequirements.txt
```

Cleanup:

```sh
exit
nix-collect-garbage -d
```

Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
