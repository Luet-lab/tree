#!/bin/sh
set -ex
apk --no-cache add ca-certificates tar wget xz rsync
# NOTE: For now use zen variant.
wget https://build.funtoo.org/1.4-release-std/x86-64bit/amd64-zen/stage3-latest.tar.xz -O /rootfs.tar.xz
mkdir /funtoo && cd /funtoo && tar xJpf /rootfs.tar.xz --xattrs --numeric-owner && rm /rootfs.tar.xz
ls -l /funtoo/
rsync -A -a --delete --numeric-ids --recursive -d -H --one-file-system --xattrs --exclude '/funtoo/*'  --exclude '/etc/resolv.conf'  --exclude '/etc/hostname'  --exclude '/sys/' --exclude '/etc/hosts'  --exclude '/sys/*' --exclude '/proc/*' --exclude '/dev/pts/*' /funtoo/ /
rm -rf /funtoo
