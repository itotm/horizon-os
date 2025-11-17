#!/bin/bash
set -ouex pipefail

FEDORA_VERSION=${FEDORA_VERSION:-43}

mv /opt /opt_
mkdir /opt

dnf5 -y config-manager addrepo --from-repofile=https://dl.winehq.org/wine-builds/fedora/${FEDORA_VERSION}/winehq.repo
dnf5 -y install winehq-staging

mkdir -p /var/opt
mv /opt/* /var/opt/
mv /opt_ /opt

wget --no-hsts https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x ./winetricks
mkdir -p /var/usrlocal/bin
mv ./winetricks /var/usrlocal/bin/winetricks

./ctx/cleanup.sh
