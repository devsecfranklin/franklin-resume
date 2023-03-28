# Auth

```sh
for key in ~/.ssh/id_*; do ssh-keygen -l -f "${key}"; done | uniq
ssh-keygen -t ed25519 -C "fdiaz@paloaltonetworks.com" -f ~/.ssh/id_ed25519_work -o -a 100 
```

## Mac

If you’re using macOS Sierra 10.12.2 or later, to load the keys automatically and store the passphrases in the Keychain, you need to configure your ~/.ssh/config file:

```sh
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
  IdentityFile ~/.ssh/id_rsa # Keep any old key files if you want
```

Once the SSH config file is updated, add the private-key to the SSH agent:

```sh
ssh-add -K ~/.ssh/id_ed25519
```

