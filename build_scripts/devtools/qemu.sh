#!/bin/bash
set -ouex pipefail

QEMU_PACKAGES=(
    qemu-kvm
    quickemu
    libvirt
    cockpit-machines
)
dnf5 -y install "${QEMU_PACKAGES[@]}"

./ctx/cleanup.sh
