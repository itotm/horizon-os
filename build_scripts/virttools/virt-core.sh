#!/bin/bash
set -oue pipefail

# Core di virtualizzazione (qemu, libvirt, edk2)
VIRT_CORE_PACKAGES=(
    libvirt
    qemu-kvm
)
dnf5 -y install "${VIRT_CORE_PACKAGES[@]}"
