#!/bin/bash
set -ouex pipefail

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
    bat
    du-dust
    duf
    procs
    hyperfine
    tldr
    lsd
    ncdu
    iscan-firmware
)
dnf5 -y install "${INSTALL_PACKAGES[@]}"

dnf5 -y config-manager setopt fedora-cisco-openh264.enabled=1
dnf5 -y install openh264 mozilla-openh264

systemctl enable podman.socket

cp -r /ctx/sys_files/* /
systemctl enable horizon-user-setup.service

./ctx/cleanup.sh
