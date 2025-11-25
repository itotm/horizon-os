#!/bin/bash
set -ouex pipefail

if [ "${DISABLE_REPOS:-true}" = "true" ]; then
	sed -i 's/^enabled=.*/enabled=0/' /etc/yum.repos.d/*.repo
fi
dnf5 -y clean all

./ctx/download-github.sh https://github.com/itotm/eleven-twilight/releases/download/1.0/ElevenTwilight.tar.gz /usr/share/icons > /dev/null
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/releases/download/v1.0/ClearSimple.colors.tar.gz /usr/share/color-schemes > /dev/null
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/releases/download/v1.0/ClearSimple.tar.gz /usr/share/plasma/desktoptheme > /dev/null
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/releases/download/v1.0/colored-plasma-logo.tar.gz /usr/share/plasma/look-and-feel > /dev/null
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/tree/main/Konsole /usr/share/konsole > /dev/null

systemctl enable sshd
systemctl enable podman.socket

cp -r /ctx/sys_files/* /
systemctl enable horizon-setup-system.service
systemctl enable horizon-update.timer

cat > /etc/xdg/kcm-about-distrorc <<EOF
[General]
Variant=HorizonOS ${IMAGE_VERSION}
Website=https://github.com/itotm/horizon-os
EOF

echo "${IMAGE_VERSION}" > /etc/horizon-version

