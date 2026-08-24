#!/bin/bash
set -oue pipefail

fc-cache -f

sed -i 's/^enabled=.*/enabled=0/' /etc/yum.repos.d/*.repo

echo "----------> Cleaning up dnf cache"
dnf5 -y autoremove
dnf5 -y clean all

echo "----------> Downloading GitHub assets"
./ctx/download-github.sh https://github.com/itotm/eleven-twilight/releases/download/v2.2/ElevenTwilight-2.2.tar.gz /usr/share/icons
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
./ctx/download-github.sh https://github.com/itotm/plasma-wallpaper-potd-enhanced/releases/download/v1.5.4/com.plasma.wallpaper.potd-enhanced-1.5.4.tar.gz /usr/share/plasma/wallpapers
sleep 1
./ctx/download-github.sh https://github.com/itotm/kickoff-simplified/releases/download/v1.3.5/org.kde.plasma.kickoff-simplified-1.3.5.tar.gz /usr/share/plasma/plasmoids
sleep 1
./ctx/download-github.sh https://github.com/itotm/plymouth-themes/releases/download/v1.1/fedora-logo-spinner.tar.gz /usr/share/plymouth/themes

plymouth-set-default-theme fedora-logo-spinner

echo "----------> Regenerating initramfs"
KERNEL_VERSION=$(ls -1 /usr/lib/modules/ | head -n1)
echo "Kernel: ${KERNEL_VERSION}"
depmod -a "${KERNEL_VERSION}"
INITRAMFS_IMAGE="/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"
echo "Starting initramfs regeneration for kernel version: ${KERNEL_VERSION}"
    dracut \
    --kver "${KERNEL_VERSION}" \
    --force \
    --add 'ostree' \
    --no-hostonly \
    --reproducible \
    "${INITRAMFS_IMAGE}"

chmod 0600 "${INITRAMFS_IMAGE}"

cp -r /ctx/sys_files/* /
systemctl enable horizon-setup-system.service

cat > /etc/xdg/kcm-about-distrorc <<EOF
[General]
Variant=HorizonOS ${IMAGE_VERSION}
Website=https://github.com/itotm/horizon-os
EOF

sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"HorizonOS ${IMAGE_VERSION}\"/" /usr/lib/os-release

echo "${IMAGE_VERSION}" > /etc/horizon-version

echo "----------> Sqlite cleanup"
sqlite3 /usr/lib/sysimage/rpm/rpmdb.sqlite "PRAGMA wal_checkpoint(TRUNCATE); PRAGMA journal_mode=DELETE;"

echo "----------> Final package count"
rpm -qa | wc -l

echo "----------> Final disk usage"
df -h
