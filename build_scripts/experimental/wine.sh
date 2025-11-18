#!/bin/bash
set -ouex pipefail

FEDORA_VERSION=${FEDORA_VERSION:-43}

dnf5 -y config-manager addrepo --from-repofile=https://dl.winehq.org/wine-builds/fedora/${FEDORA_VERSION}/winehq.repo
./ctx/install-opt.sh winehq-staging

wget --no-hsts https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x ./winetricks
mkdir -p /var/usrlocal/bin
mv ./winetricks /var/usrlocal/bin/winetricks

./ctx/cleanup.sh
