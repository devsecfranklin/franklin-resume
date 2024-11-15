#! /bin/sh

# https://hub.docker.com/r/dougrabson/freebsd-minimal

REGISTRY=docker.io/dougrabson
REPO=/usr/obj/usr/src/repo/FreeBSD:13:amd64/latest
VER=13.1

c=$(sudo buildah from scratch)
m=$(sudo buildah mount $c)

sudo pkg --rootdir $m add $REPO/FreeBSD-runtime-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-clibs-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-rc-$VER.pkg

sudo pkg --rootdir $m add $REPO/FreeBSD-libarchive-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-libucl-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-libbz2-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-liblzma-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-openssl-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-fetch-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-pkg-bootstrap-$VER.pkg

sudo buildah unmount $c
i=$(sudo buildah commit $c)
sudo buildah rm $c
sudo buildah tag $i $REGISTRY/freebsd-minimal:13.1
sudo buildah tag $i $REGISTRY/freebsd-minimal:13
