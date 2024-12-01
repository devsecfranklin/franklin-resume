Role Name
=========

Ansible role for gnupg related stuff.

```sh
gpg --list-secret-keys --keyid-format=long
gpg --list-public-keys --keyid-format=long
gpg --full-generate-key
gpgconf --list-dirs # all the directories
gpg --keyserver hkps://keys.openpgp.org:443 --send-key "3FDD B22B E65C FCC1 9BDF  37B2 7C02 032F 97E9 7720" # add key to keyserver
```

* keyringer

*[https://github.com/quarkslab/keyringer](https://github.com/quarkslab/keyringer)

```sh
keyringer vault init /home/franklin/.password-store git@github.com:devsecfranklin/vault.git
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

Example Playbook
----------------

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
