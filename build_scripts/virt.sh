#!/bin/bash
set -oue pipefail

VIRT_PACKAGES=(
    cockpit-machines
    distrobox
    libvirt
    qemu-kvm
    virt-manager
    virt-viewer
)
dnf5 -y install "${VIRT_PACKAGES[@]}"

./ctx/cleanup.sh
