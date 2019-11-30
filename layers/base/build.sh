#!/bin/sh
set -ex
apk --no-cache add ca-certificates tar wget xz rsync
version=$(wget -O -  http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-systemd.txt --quiet | tail -n 1 | awk 'match($1, /^[0-9]+/)  { print substr($1, RSTART, RLENGTH) }')
wget http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-systemd/stage3-amd64-systemd-${version}.tar.bz2 -O /rootfs.tar.bz2
mkdir /gentoo && cd /gentoo && tar xpf /rootfs.tar.bz2 --xattrs --numeric-owner && rm /rootfs.tar.bz2
rsync -A -a --delete --numeric-ids --recursive -d -H --one-file-system --xattrs --exclude '/gentoo/*'  --exclude '/etc/resolv.conf'  --exclude '/etc/hostname'  --exclude '/sys/' --exclude '/etc/hosts'  --exclude '/sys/*' --exclude '/proc/*' --exclude '/dev/pts/*' /gentoo/ /
rm -rf /gentoo
