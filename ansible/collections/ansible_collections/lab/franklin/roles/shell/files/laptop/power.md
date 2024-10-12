# debian laptop

This is for lid close power issues.

```sh
sudo apt install pm-utils
sudo cp /etc/systemd/logind.conf  /etc/systemd/logind.conf.back
```

edit the hibernate options in /etc/systemd/logind.conf
