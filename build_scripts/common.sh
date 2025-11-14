#!/bin/bash
set -ouex pipefail

sed -i 's/^enabled=.*/enabled=0/' /etc/yum.repos.d/*.repo

systemctl enable sshd

cat > /etc/inputrc <<EOF
set completion-ignore-case On
EOF

./ctx/download_github.sh https://github.com/itotm/plasma-colors/tree/main/color-schemes /usr/share/color-schemes
./ctx/download_github.sh https://github.com/itotm/plasma-colors/tree/main/ClearSimple /usr/share/plasma/desktoptheme/ClearSimple
./ctx/download_github.sh https://github.com/itotm/plasma-colors/tree/main/colored-plasma-logo /usr/share/plasma/look-and-feel/colored-plasma-logo
./ctx/download_github.sh https://github.com/itotm/plymouth-themes/tree/main/fedora-logo/fedora-logo /usr/share/plymouth/themes/fedora-logo


BUILD_DATE=$(date +'%Y%m%d')
BUILD_NUMBER=${BUILD_NUMBER:-1}
VERSION="v${BUILD_DATE}.${BUILD_NUMBER}"

cat > /etc/xdg/kcm-about-distrorc <<EOF
[General]
Variant=HorizonOS ${VERSION}
Website=https://github.com/itotm/horizon-os
EOF

echo "${VERSION}" > /etc/horizon-version
