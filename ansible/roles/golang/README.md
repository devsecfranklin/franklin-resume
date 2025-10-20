# Go Language

## OpenBSD

- [Go Wiki: Go on OpenBSD](https://go.dev/wiki/OpenBSD)
- ulimits (/etc/login.conf)

Edit /etc/login.conf so that the staff class has the proper settings.
The following is a working example of the staff class:

```sh
staff:\
       :datasize-cur=infinity:\
       :datasize-max=infinity:\
       :datasize=infinity:\
       :openfiles-cur=4096:\
       :maxproc-max=512:\
       :maxproc-cur=512:\
       :ignorenologin:\
       :requirehome@:\
       :tc=default:
```

- If the database file /etc/login.conf.db exists, you need to rebuild it
with: `doas cap_mkdb /etc/login.conf`
- Ensure that the user you intend to build Go with is in the staff login
class: `usermod -L staff franklin`
