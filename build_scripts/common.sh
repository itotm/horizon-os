#!/bin/bash
set -ouex pipefail

if [ "${DISABLE_REPOS:-true}" = "true" ]; then
	sed -i 's/^enabled=.*/enabled=0/' /etc/yum.repos.d/*.repo
fi

./ctx/download-github.sh https://github.com/itotm/eleven-twilight/releases/download/1.0/ElevenTwilight.tar.gz /usr/share/icons
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/releases/download/v1.0/ClearSimple.colors.tar.gz /usr/share/color-schemes
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/releases/download/v1.0/ClearSimple.tar.gz /usr/share/plasma/desktoptheme/ClearSimple
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/releases/download/v1.0/colored-plasma-logo.tar.gz /usr/share/plasma/look-and-feel/colored-plasma-logo
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/blob/main/Konsole/BreezeBlue.colorscheme /usr/share/konsole

systemctl enable sshd
systemctl enable podman.socket

cp -r /ctx/sys_files/* /
systemctl enable horizon-setup-system.service
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

dnf5 -y clean all
rm -rf /tmp/* || true
rm -rf /var/!(cache)
rm -rf /var/cache/!(rpm-ostree)