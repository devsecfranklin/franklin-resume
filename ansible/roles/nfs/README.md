# nfs_sssd

This is the role for storage related configurations.

## Storage hosts

* Snowy - An upcycled desktop running Debian
* Storage1 - A raspi w/3 SSD attached. Also has a 3TB external.

## NFSv4 and Kerberos

* [NFSv4 and Kerberos in Debian](https://wiki.debian.org/NFS/Kerberos)

Find the correct hostname for each principal:

```sh
getent hosts $(hostname) | awk '{print $1; exit}' | xargs getent hosts | awk '{print $2}'
```

Add the NFS principal for the hosts to the KDC:

```sh
kadmin -p  root/admin@LAB.BITSMASHER.NET
addprinc -randkey nfs/snowy.lab.bitsmasher.net@LAB.BITSMASHER.NET
ktadd nfs/snowy.lab.bitsmasher.net@LAB.BITSMASHER.NET host/snowy.lab.bitsmasher.net@LAB.BITSMASHER.NET ldap/snowy.lab.bitsmasher.net@LAB.BITSMASHER.NET
```

Update the server side NFS export. In ansible this is done under `defaults/main.yml`

```sh
# 'no_subtree_check' is specified to get rid of warning messages
#    about the default value changing. This is the default value
/mnt/clusterfs   10.10.8.0/21(rw,sync,no_subtree_check,sec=krb5)
```

## Troubleshooting

* Your /etc/krb5.keytab file should only be readable by root.
* Try enabling verbose messages for rpc.gssd by adding RPCGSSDOPTS="-vvv" to /etc/default/nfs-common
* If autodetection fails, edit /etc/default/nfs-common to enable idmapd, gssd on the
   clients + server and /etc/default/nfs-kernel-server to enable svcgssd on the server.
* Ensure your Kerberos domains are correctly configured. This includes in your krb5.conf file;
  nfs seems to use it to get the realm. This also seems to imply that servers must be in the
  form of HOST.domain, where domain is common to both the server and client.
* Make sure your domain is specified in /etc/idmapd.conf
* When tinkering with your export file, make sure to re-export with exportfs -ra
* `rpc.svcgssd` on the server looks for the prinicpal nfs/reverse_lookup_of_your_ip_address
  (not necessary nfs/hostnameT). Check if the principal matches the return value of the above
  command. If necessary, you can specify this in your /etc/hosts file.
* Errors about corrupt keyfiles in auth.log often can be resolved by deleting and re-creating keys and keyfiles.
* Errors about "Additional pre-authentication required" in auth.log indicate that not the
  right keys are in the keyfiles or that some wrong encryption ciphers have been used
  (the default ciphers should be ok). The server should only need a server key inside, the client
  only the client key. Restart all nfs services after changing the keyfiles.
* "Server not found in Kerberos database" in auth.log indicate that the key names of client
  or server and the respective hostnames do not match.
* If all else fails, restart your daemons. Also try restarting nscd, as that can cause
  hard-to-spot caching errors.
