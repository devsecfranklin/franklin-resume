# Kerberos

files

```sh
/etc/krb5.keytab
/usr/share/krb5-kdc
/etc/krb5kdc/kdc.conf
/var/lib/krb5kdc
```

## Create a kadmind Keytab

* [Create a kadmind Keytab](https://web.mit.edu/kerberos/krb5-1.5/krb5-1.5.4/doc/krb5-install/Create-a-kadmind-Keytab-_0028optional_0029.html)

The kadmind keytab is the key that the legacy admininstration daemons kadmind4 and v5passwdd
will use to decrypt administrators' or clients' Kerberos tickets to determine whether or not
they should have access to the database. You need to create the kadmin keytab with entries for
the principals `kadmin/admin` and `kadmin/changepw`.

## SSSD integration with Active Directory

The System Security Services Daemon is software originally developed for the Linux
operating system that provides a set of daemons to manage access to remote\
directory services and authentication mechanisms.

## SSH

```sh
for key in ~/.ssh/id_*; do ssh-keygen -l -f "${key}"; done | uniq
ssh-keygen -t ed25519 -C "fdiaz@paloaltonetworks.com" -f ~/.ssh/id_ed25519_work -o -a 100
```

### Mac

If you’re using macOS Sierra 10.12.2 or later, to load the keys automatically and store
the passphrases in the Keychain, you need to configure your ~/.ssh/config file:

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
