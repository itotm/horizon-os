#!/bin/bash
set -oue pipefail

if [ "${DISABLE_REPOS:-true}" = "true" ]; then
	sed -i 's/^enabled=.*/enabled=0/' /etc/yum.repos.d/*.repo
fi

dnf5 -y autoremove
dnf5 -y clean all

./ctx/download-github.sh https://github.com/itotm/eleven-twilight/releases/download/1.0.1/ElevenTwilight.tar.gz /usr/share/icons
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/releases/download/v1.0/ClearSimple.colors.tar.gz /usr/share/color-schemes
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/releases/download/v1.0/ClearSimple.tar.gz /usr/share/plasma/desktoptheme
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/releases/download/v1.0/colored-plasma-logo.tar.gz /usr/share/plasma/look-and-feel
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/releases/download/v1.0/breeze-cursors-light-plasma5.tar.gz /usr/share/icons
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-colors/tree/main/Konsole /usr/share/konsole
sleep 1
./ctx/download-github.sh https://github.com/itotm/plasma-wallpaper-potd-enhanced/releases/download/v1.4.2/com.plasma.wallpaper.potd-enhanced-1.4.2.tar.gz /usr/share/plasma/wallpapers
sleep 1
./ctx/download-github.sh https://github.com/itotm/kickoff-simplified/releases/download/v1.3.3/org.kde.plasma.kickoff-simplified-1.3.3.tar.gz /usr/share/plasma/plasmoids

cp -r /ctx/sys_files/* /
systemctl enable horizon-setup-system.service

cat > /etc/xdg/kcm-about-distrorc <<EOF
[General]
Variant=HorizonOS ${IMAGE_VERSION}
Website=https://github.com/itotm/horizon-os
EOF

sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"HorizonOS ${IMAGE_VERSION}\"/" /usr/lib/os-release

echo "${IMAGE_VERSION}" > /etc/horizon-version
