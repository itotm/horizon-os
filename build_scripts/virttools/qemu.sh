#!/bin/bash
set -oue pipefail

QEMU_PACKAGES=(
    qemu-kvm
    libvirt
    cockpit-machines
    quickemu
)
dnf5 -y install "${QEMU_PACKAGES[@]}"

./ctx/cleanup.sh
