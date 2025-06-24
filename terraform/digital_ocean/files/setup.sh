#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

# set up the game server on digital ocean

DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y make git direnv screen neofetch figlet cowsay mlocate

groupadd -g 9001 engr
useradd -d /home/franklin -g 9001 -m -s /bin/bash -u 9001 franklin
su  - franklin
mkdir /home/franklin/.ssh && chmod 700 /home/franklin/.ssh
mkdir /home/franklin/workspace
git clone git@github.com:devsecfranklin/game-server-dontstarvetogether.git workspace/game-server-dontstarvetogether

# install steam
add-apt-repository -y -n -U http://deb.debian.org/debian -c non-free -c non-free-firmware
apt -y install software-properties-common
sudo DEBIAN_FRONTEND=noninteractive apt-get install podman containers-storage docker-compose software-properties-common -y
sudo apt-add-repository non-free
sudo tee /etc/apt/sources.list.d/steam-stable.list <<'EOF'
deb [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
deb-src [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
EOF
sudo dpkg --add-architecture i386
sudo apt-get update
apt-get -y  install steamcmd # yes use this the CLI tool for steam game servers

steamcmd +login anonymous +app_update 343050 validate +quit # download the server appliction


# this is GUI front end, no bueno
# sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
#   libgl1-mesa-dri:amd64 \
#   libgl1-mesa-dri:i386 \
#   libgl1-mesa-glx:amd64 \
#   libgl1-mesa-glx:i386 \
#   steam-launcher

# set up dst user 
ln -s /home/franklin/workspace/game-server-dontstarvetogether /home/dst
sudo useradd -d /home/dst -g 60 -M -s /bin/bash -u 6969 dst
sudo chown -R dst:games /home/franklin/workspace/game-server-dontstarvetogether
# add users to docker, games, and engr groups
su - dst
mkdir /home/dst/.ssh && chmod 700 /home/dst/.ssh

# mkdir -p ~/.klei/DoNotStarveTogether

# run steamcmd
# login chuggalugg

function tls_cert() {
    mv /usr/share/nginx/html /usr/share/nginx/html.old && ln -s /usr/share/nginx/website/static/games /usr/share/nginx/html
    sudo apt -y install certbot python3-certbot-nginxv
    nginx -c /etc/nginx/nginx.conf -t # check the nginx config
    certbot certificates
    systemctl status certbot.timer
    certbot renew --dry-run
    chown -R www-data:www-data /etc/nginx

}