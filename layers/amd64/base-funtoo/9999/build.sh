#!/bin/sh
set -ex
apk --no-cache add ca-certificates tar wget xz rsync
wget wget https://build.funtoo.org/funtoo-current/x86-64bit/generic_64/stage3-latest.tar.xz -O /rootfs.tar.bz2
mkdir /gentoo && cd /gentoo && tar xpf /rootfs.tar.bz2 --xattrs --numeric-owner && rm /rootfs.tar.bz2
rsync -A -a --delete --numeric-ids --recursive -d -H --one-file-system --xattrs --exclude '/gentoo/*'  --exclude '/etc/resolv.conf'  --exclude '/etc/hostname'  --exclude '/sys/' --exclude '/etc/hosts'  --exclude '/sys/*' --exclude '/proc/*' --exclude '/dev/pts/*' /gentoo/ /
rm -rf /gentoo
