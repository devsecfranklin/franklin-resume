#!/bin/sh

#wget https://download.freebsd.org/ftp/releases/ISO-IMAGES/13.2/FreeBSD-13.2-RELEASE-amd64-bootonly.iso

cat -> docker-compose.yml << EOL
---
version: "3"
services:
    freebsd-via-qemu:
        image: jkz0/qemu:latest
        cap_add:
            - NET_ADMIN
        devices:
            - /dev/net/tun
            - /dev/kvm
        volumes:
            - ./FreeBSD-13.2-RELEASE-amd64-bootonly.iso:/image
        restart: always
...sudo apt-get install qemu-kvm qemu virt-manager virt-viewer libvirt-bin
EOL
docker-compose up -d
