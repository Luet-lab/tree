#!/bin/bash

# Setting locale.conf
for f in /etc/env.d/02locale /etc/locale.conf; do
    echo LANG=en_US.UTF-8 > "${f}"
    echo LANGUAGE=en_US.UTF-8 >> "${f}"
    echo LC_ALL=en_US.UTF-8 >> "${f}"
done

# Defyning /usr/local/portage configuration
mkdir /usr/local/portage
mkdir -p /usr/local/portage/metadata/
mkdir -p /usr/local/portage/profiles/
echo "masters = gentoo" > /usr/local/portage/metadata/layout.conf
echo "user_defined" > /usr/local/portage/profiles/repo_name

#mkdir -p /etc/portage/package.keywords/
#echo "app-admin/equo ~amd64
#sys-apps/entropy ~amd64
#" > /etc/portage/package.keywords/00-sabayon.package.keywords

#mkdir -p /etc/portage/package.use/
#echo "dev-lang/python sqlite
#sys-apps/file python
#" > /etc/portage/package.use/00-sabayon.package.use

eselect profile list
eselect profile set default/linux/amd64/17.0/systemd

emerge layman -vt -j 3 || {
  echo "Error on emerge layman"
  exit 1
}

layman -S && echo "y" | layman -a sabayon
echo "y" | layman -a sabayon-distro

sed -i 's/repos\.conf/make.conf/' /etc/layman/layman.cfg

layman-updater -R

# Currently gentoo portage doesn't support definition of
# mask packages with ::repo inside overlay profiles.
wget https://raw.githubusercontent.com/Sabayon/sabayon-sark/develop/sark-functions.sh -O /sbin/sark-functions.sh
chmod 755 /sbin/sark-functions.sh
# Create mask file of upstream packages
source /sbin/sark-functions.sh
sabayon_mask_upstream_pkgs

# Will be supply by sabayon-sark package
rm -v /sbin/sark-functions.sh

# Specifying a Sabayon profile
eselect profile set "sabayon-distro:default/linux/amd64/17.0/sabayon"

gcc-config -c
gcc-config 1
. /etc/profile

# Remove sys-apps/openrc from gentoo stage3
emerge --unmerge sys-apps/openrc

# Enforce choosing only python2.7 for now, cleaning others
eselect python set python3.6

# default for next stage(s)
#echo "nameserver 8.8.8.8" > /etc/resolv.conf

# set default shell
chsh -s /bin/bash

rm -rf /etc/make.profile

# removing workaround, it is fixed in Entropy
rm -rf /etc/init.d/functions.sh
