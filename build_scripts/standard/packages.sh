#!/bin/bash
set -oue pipefail

REMOVE_PACKAGES=(
    kjournald
    plasma-discover-rpm-ostree
    sddm-kcm
)
dnf5 -y remove "${REMOVE_PACKAGES[@]}"

dnf5 -y config-manager setopt fedora-cisco-openh264.enabled=1

INSTALL_PACKAGES=(
    bat
    btop
    cascadia-fonts-all
    du-dust
    duf
    fastfetch
    fd
    fzf
    htop
    hunspell-it
    hwinfo
    hyperfine
    lm_sensors
    lsd
    mc
    mozilla-openh264
    ncdu
    openh264
    policycoreutils-gui
    procs
    rclone
    rclone-browser
    ripgrep
    tldr
)
dnf5 -y install "${INSTALL_PACKAGES[@]}"

./ctx/cleanup.sh
