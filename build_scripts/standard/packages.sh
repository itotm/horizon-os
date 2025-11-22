#!/bin/bash
set -ouex pipefail

REMOVE_PACKAGES=(
    plasma-discover-rpm-ostree
)
dnf5 -y remove "${REMOVE_PACKAGES[@]}"

INSTALL_PACKAGES=(
    bat
    cascadia-fonts-all
    distrobox
    du-dust
    duf
    fastfetch
    fd
    fzf
    htop
    hunspell-it
    hwinfo
    hyperfine
    iscan-firmware
    lm_sensors
    lsd
    mc
    ncdu
    procs
    rclone
    ripgrep
    tldr
    zoxide
)
dnf5 -y install "${INSTALL_PACKAGES[@]}"

dnf5 -y config-manager setopt fedora-cisco-openh264.enabled=1
dnf5 -y install openh264 mozilla-openh264

systemctl enable podman.socket

cp -r /ctx/sys_files/* /

systemctl enable horizon-setup.service

./ctx/cleanup.sh
