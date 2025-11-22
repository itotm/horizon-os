#!/bin/bash
set -ouex pipefail

if [ "${DISABLE_REPOS:-true}" = "true" ]; then
	sed -i 's/^enabled=.*/enabled=0/' /etc/yum.repos.d/*.repo
fi
dnf5 -y clean all

./ctx/download-github.sh https://github.com/itotm/eleven-twilight/releases/download/1.0/ElevenTwilight.tar.gz /usr/share/icons

./ctx/download-github.sh https://github.com/itotm/plasma-colors/tree/main/color-schemes /usr/share/color-schemes
./ctx/download-github.sh https://github.com/itotm/plasma-colors/tree/main/ClearSimple /usr/share/plasma/desktoptheme/ClearSimple
./ctx/download-github.sh https://github.com/itotm/plasma-colors/tree/main/colored-plasma-logo /usr/share/plasma/look-and-feel/colored-plasma-logo
./ctx/download-github.sh https://github.com/itotm/plasma-colors/tree/main/Konsole /usr/share/konsole

./ctx/download-github.sh https://github.com/itotm/plymouth-themes/tree/main/fedora-logo/fedora-logo /usr/share/plymouth/themes/fedora-logo

systemctl enable sshd
systemctl enable horizon-update.timer

BUILD_DATE=$(date +'%Y%m%d')
BUILD_NUMBER=${BUILD_NUMBER:-1}
VERSION="v${BUILD_DATE}.${BUILD_NUMBER}"

cat > /etc/xdg/kcm-about-distrorc <<EOF
[General]
Variant=HorizonOS ${VERSION}
Website=https://github.com/itotm/horizon-os
EOF

echo "${VERSION}" > /etc/horizon-version
