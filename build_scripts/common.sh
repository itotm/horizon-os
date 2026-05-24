#!/bin/bash
set -oue pipefail

if [ "${DISABLE_REPOS:-true}" = "true" ]; then
	sed -i 's/^enabled=.*/enabled=0/' /etc/yum.repos.d/*.repo
fi

dnf5 -y autoremove
dnf5 -y clean all

./ctx/download-github.sh https://github.com/itotm/eleven-twilight/releases/download/v2.0/ElevenTwilight-2.0.tar.gz /usr/share/icons
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
./ctx/download-github.sh https://github.com/itotm/plasma-wallpaper-potd-enhanced/releases/download/v1.4.3/com.plasma.wallpaper.potd-enhanced-1.4.3.tar.gz /usr/share/plasma/wallpapers
sleep 1
./ctx/download-github.sh https://github.com/itotm/kickoff-simplified/releases/download/v1.3.4/org.kde.plasma.kickoff-simplified-1.3.4.tar.gz /usr/share/plasma/plasmoids
sleep 1
./ctx/download-github.sh https://github.com/itotm/plymouth-themes/releases/download/v1.1/fedora-logo-spinner.tar.gz /usr/share/plymouth/themes

plymouth-set-default-theme fedora-logo-spinner

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

# Cleanup for bootc container lint
# Remove kernel files from /boot (kept in /usr/lib/modules)
if [ -d /boot ]; then
    rm -f /boot/System.map-*
    rm -f /boot/config-*
    rm -f /boot/initramfs-*
    rm -f /boot/symvers-*.zst
    rm -f /boot/loader/entries/*.conf.bak 2>/dev/null || true
fi

# Clean /run and /tmp
rm -rf /run/cockpit
rm -rf /run/dnf
rm -rf /run/systemd

# Clean /tmp
tmpfiles --remove 2>/dev/null || true

# Clean /var tmpfiles entries
rm -f /var/lib/tmpfiles.d/*.conf 2>/dev/null || true

# Remove PackageKit and dnf cache directories
dnf5 clean all
rm -rf /var/lib/PackageKit
rm -rf /var/lib/dnf/repos
rm -rf /var/lib/dnf/system-repo.lock

# Remove other var cleanup entries
dnf5 -y autoremove
rm -rf /var/lib/sepolgen
rm -rf /var/lib/iscsi
rm -rf /var/lib/augeas
rm -rf /var/lib/selinux
rm -rf /var/lib/audit
rm -rf /var/cache/dnf
rm -rf /var/cache/mock
rm -rf /var/tmp

# Clean up temporary files
find /var -type f -name "*.log" -delete 2>/dev/null || true
find /var -type f -name "*.gz" -delete 2>/dev/null || true
find /var -type f -name "*.gz.old" -delete 2>/dev/null || true

# Clean DNF history
dnf5 history undo 0 2>/dev/null || true
dnf5 history userhistory --delete 2>/dev/null || true
