#!/bin/bash
set -ouex pipefail

dnf5 -y config-manager setopt fedora-cisco-openh264.enabled=1

# Packages
REMOVE_PACKAGES=(
    plasma-discover-rpm-ostree
)
dnf5 -y remove "${REMOVE_PACKAGES[@]}"

INSTALL_PACKAGES=(
    cascadia-fonts-all
    mc
    htop
    fastfetch
    hwinfo
    hunspell-it
    qemu-kvm
    cockpit
    cockpit-machines
    cockpit-podman
    distrobox
    syncthing
    tailscale
)
dnf5 -y install "${INSTALL_PACKAGES[@]}"

# Services
systemctl enable cockpit.socket
systemctl enable podman.socket
systemctl enable sshd
systemctl enable tailscaled
