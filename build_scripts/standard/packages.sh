#!/bin/bash
set -ouex pipefail

flatpak remote-add --system flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-modify --system --enable flathub

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
    fzf
    zoxide
    ripgrep
    fd
    cascadia-fonts-all
    hunspell-it
    distrobox
    iscan-firmware
)
dnf5 -y install "${INSTALL_PACKAGES[@]}"

dnf5 -y copr enable terjeros/eza
dnf5 -y install eza
dnf5 -y copr disable terjeros/eza

dnf5 -y config-manager setopt fedora-cisco-openh264.enabled=1
dnf5 -y install openh264 mozilla-openh264

systemctl enable podman.socket

./ctx/cleanup.sh
