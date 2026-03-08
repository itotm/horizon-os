#!/bin/bash
set -oue pipefail

VIRT_PACKAGES=(
    cockpit-machines
    distrobox
    libvirt
    podman-compose
    qemu-kvm
    virt-manager
    virt-viewer
)
dnf5 -y install "${VIRT_PACKAGES[@]}"
