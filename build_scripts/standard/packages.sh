#!/bin/bash
set -oue pipefail

REMOVE_PACKAGES=(
    kjournald
    plasma-discover-rpm-ostree
)
dnf5 -y remove "${REMOVE_PACKAGES[@]}"

INSTALL_PACKAGES=(
    bat
    btop
    cascadia-mono-fonts
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
    rclone-browser
    ripgrep
    tldr
)
dnf5 -y install "${INSTALL_PACKAGES[@]}"

dnf5 -y config-manager setopt fedora-cisco-openh264.enabled=1
dnf5 -y install openh264 mozilla-openh264

./ctx/cleanup.sh
