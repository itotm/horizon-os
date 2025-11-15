#!/bin/bash
set -ouex pipefail

# Usa la versione di Fedora da variabile d'ambiente, fallback a 43
FEDORA_VERSION=${FEDORA_VERSION:-43}

dnf5 -y config-manager addrepo --from-repofile=https://dl.winehq.org/wine-builds/fedora/${FEDORA_VERSION}/winehq.repo
dnf5 -y install winehq-staging

wget --no-hsts https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x ./winetricks
mkdir -p /var/usrlocal/bin
mv ./winetricks /var/usrlocal/bin/winetricks

./ctx/cleanup.sh
