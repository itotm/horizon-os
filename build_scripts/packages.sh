#!/bin/bash
set -ouex pipefail

# Packages
REMOVE_PACKAGES=(
    plasma-discover-rpm-ostree
)
dnf5 -y remove "${REMOVE_PACKAGES[@]}"

INSTALL_PACKAGES=(
    mc
    htop
    fastfetch
    hwinfo
    lm_sensors
    curl
    fzf
    zoxide
    ripgrep
    fd
    cascadia-fonts-all
    hunspell-it
    cockpit
    cockpit-podman
    distrobox
    syncthing
    tailscale
)
dnf5 -y install "${INSTALL_PACKAGES[@]}"

dnf5 -y copr enable terjeros/eza
dnf5 -y install eza
dnf5 -y copr disable terjeros/eza

dnf5 -y config-manager setopt fedora-cisco-openh264.enabled=1
dnf5 -y install openh264 mozilla-openh264
dnf5 -y config-manager setopt fedora-cisco-openh264.enabled=0

# Services
systemctl enable cockpit.socket
systemctl enable podman.socket
systemctl enable sshd
systemctl enable tailscaled
