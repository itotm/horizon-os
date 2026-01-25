#!/bin/bash
set -oue pipefail

./ctx/download-github.sh https://github.com/itotm/plymouth-themes/releases/download/v1.0/fedora-logo.tar.gz /usr/share/plymouth/themes

plymouth-set-default-theme fedora-logo

KERNEL_VERSION=$(ls -1 /usr/lib/modules/ | head -n1)
INITRAMFS_IMAGE="/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"
echo "Starting initramfs regeneration for kernel version: ${KERNEL_VERSION}"
    dracut \
    --kver "${KERNEL_VERSION}" \
    --force \
    --add 'ostree' \
    --omit "rootfs-block" \
    --no-hostonly \
    --reproducible \
    "${INITRAMFS_IMAGE}"

chmod 0600 "${INITRAMFS_IMAGE}"
