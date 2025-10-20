# Keyboard Backlight

* Create a new system directory:

```sh
if [ ! -e "/usr/lib/systemd/system" ] ; then 
mkdir /usr/lib/systemd/system
fi
```

* Create new service:

/usr/lib/systemd/system/asus-kbd-backlight.service

```sh
[Unit]
Description=Asus Keyboard Backlight
Wants=systemd-backlight@leds:asus::kbd_backlight.service
After=systemd-backlight@leds:asus::kbd_backlight.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/chmod 666 /sys/class/leds/asus::kbd_backlight/brightness

[Install]
WantedBy=multi-user.target
```

* Create controller script

```sh
#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

path="/sys/class/leds/asus::kbd_backlight"
#path="/sys/class/leds/asus\:\:kbd_backlight"

# max should be 3
max=$(cat ${path}/max_brightness)
# step: represent the difference between previous and next brightness
step=1
previous=$(cat ${path}/brightness)

function commit {
 if [[ $1 = [0-9]* ]]
 then 
  if [[ $1 -gt $max ]]
  then 
   next=$max
  elif [[ $1 -lt 0 ]]
  then 
   next=0
  else 
   next=$1
  fi
  echo $next >> ${path}/brightness
  exit 0
 else 
  exit 1
 fi
}

case "$1" in
 up)
     commit $(($previous + $step))
  ;;
 down)
     commit $(($previous - $step))
  ;;
 max)
  commit $max
  ;;
 on)
  $0 max
  ;;
 off)
  commit 0
  ;;
 show)
  echo $previous
  ;;
 night)
  commit 1 
  ;;
 allowusers)
  # Allow members of users group to change brightness
  sudo chgrp users ${path}/brightness
  sudo chmod g+w ${path}/brightness
  ;;
 disallowusers)
  # Allow members of users group to change brightness
  sudo chgrp root ${path}/brightness
  sudo chmod g-w ${path}/brightness
  ;;
 *)
  commit $1
esac

exit 0
```
