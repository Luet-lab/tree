#!/bin/bash
# fetch the bits!

set_build_profile () {
  cd /opt
  git clone git://github.com/Sabayon/build.git sabayon-build
  cd /opt/sabayon-build/conf/intel/portage
  # keep your specific stuff in "myconf" branch:
  git checkout -b myconf
  # symlink to your <arch>:
  cp -rfv make.conf.amd64 make.conf
  cp -rfv package.env.amd64 package.env
  # add & commit
  git add make.conf package.env
  git config --global user.name "root"
  git config --global user.email "root@localhost"
  git commit -m "saving my configurations"
  # rename the gentoo /etc/make.conf and /etc/portage/:
  cd /etc/
  mv portage portage-gentoo
  #mv make.conf make.conf-gentoo
  # symlink to sabayon /etc/make.conf /etc/portage/:
  cp -rfv /opt/sabayon-build/conf/intel/portage portage
}

# Uncomment this to enable sabayon-build profile instead of sabayon profile
# from sabayon-distro overlay
# set_build_profile

# Drop portdir, we use default here
sed -i 's/PORTDIR.*//g' /etc/portage/make.conf
sed -i 's|/usr/portage.*|/var/db/repos/gentoo|g' /etc/portage/repos.conf/gentoo.conf || true
echo 'PORTDIR="/var/db/repos/gentoo"' >> /etc/portage/make.conf
sed -i 's/repos\.conf/make.conf/' /etc/layman/layman.cfg
rm -rf /var/lib/layman/make.conf || true
layman-updater -R
eselect profile list
# We need to select a profile here, because we just overwrote /etc/portage
eselect profile set 5

#emerge --update --newuse --deep --complete-graph @world
