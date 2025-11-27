#!/bin/bash
set -oue pipefail

EMU_PACKAGES=(
    cockpit-machines
    distrobox
    libvirt
    qemu-kvm
    virt-manager
)
dnf5 -y install "${EMU_PACKAGES[@]}"

./ctx/cleanup.sh
