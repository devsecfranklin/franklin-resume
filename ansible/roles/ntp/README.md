# NTP

* [How to use ntp.org](https://www.pool.ntp.org/en/use.html)

## configure

* Set the time zone: `sudo timedatectl set-timezone America/Denver`

## testing

* Be sure to use BASH not FISH or other shells.

```sh
molecule lint
molecule converge
molecule test --scenario-name default # the create, converge and destroy steps will be run one after another.
```
