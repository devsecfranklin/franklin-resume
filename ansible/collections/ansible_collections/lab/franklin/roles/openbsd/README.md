# OpenBSD

* [Managing BSD hosts with Ansible](https://docs.ansible.com/ansible/latest/os_guide/intro_bsd.html)

Assign me to some groups so I can shut down the computer and use as much memory as I need

```sh
usermod -G operator username
usermod -G staff username
usermod -G wheel username
doas usermod -L staff franklin
doas rdate time.google.com # sync the local clock to time server
```

In `/etc/login.conf update the staff class as follows:

```sh
staff:\
    :datasize-cur=4096M:\
    :datasize-max=infinity:\
    :maxproc-max=512:\
    :maxproc-cur=256:\
    :openfiles-cur=4096:\
    :openfiles-max=4096:\
:ignorenologin:\
:requirehome@:\
:tc=default:
```
