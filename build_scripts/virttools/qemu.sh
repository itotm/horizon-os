#!/bin/bash
set -oue pipefail

QEMU_PACKAGES=(
    qemu-kvm
    libvirt
    cockpit-machines
    virt-manager
)
dnf5 -y install "${QEMU_PACKAGES[@]}"

./ctx/cleanup.sh
