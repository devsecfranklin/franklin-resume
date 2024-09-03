# OpenBSD setup

- Configure doas by adding the line `permit nopass franklin` to `/etc/doas.conf`

Add my user to the staff group `usermod -G staff franklin`

## kerberos

[Kerberos and OpenBSD](https://eradman.com/posts/openbsd-kerberos.html)
[Kerberos](https://openbsd.fandom.com/wiki/Kerberos)
[Kerberos and LDAP on OpenBSD 6.2](http://www.whatsmykarma.com/blog/?p=685)

```sh
pkg_add heimdal heimdal-libs login_krb5
fish_add_path -p /usr/local/heimdal/bin
cp krb5.conf /etc/heimdal
doas route add -inet 10.10.8.0/21 10.0.0.70
```

Add this line to `/etc/rc.conf.local`

```sh
shlib_dirs=/usr/local/heimdal/lib
```

Now you can update /etc/hosts and do a `kinit`

### Kerberized logins

Modify /etc/login.conf to use Kerberos authentication. Your exact login.conf
configuration will vary depending on how you use your system, but to go
from a vanilla install to using Kerberos, just edit and comment this line
under the default login class:

```sh
    :tc=auth-defaults:\
```

And add above it:

```sh
    :auth=krb5-or-pwd:\
```

This checks Kerberos first unless the user is root. If Kerberos fails, it will use local passwords.

## MIT Kerberos

```sh
pkg_info -Q gcc
doas pkg_add wget groff bison yasm gcc-8.4.0p11
egcc -dumpmachine
git clone https://github.com/latchset/libverto.git
bash
export AUTOCONF_VERSION=2.69
export AUTOMAKE_VERSION=1.16
autoreconf -f -i
./configure
#libtoolize --copy --force --automake
make
doas make install
```

```sh
wget https://web.mit.edu/kerberos/dist/krb5/1.20/krb5-1.20.1.tar.gz

./configure 
```

## mount the drives

## Update the system

pkg_add

- colorls
- polybar
- openbsd-wallpaper
- dia
- codeblocks

```sh
doas sysupgrade
doas syspatch
```

copy in /etc/rc.conf.local

pkg_add

colorls
polybar
openbsd-wallpaper

usermod -G staff franklin

[Net Beans 14](https://netbeans.apache.org/download/nb14/nb14.html)
