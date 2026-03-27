#!/bin/bash
set -oue pipefail

REMOVE_PACKAGES=(
    kde-connect
    plasma-discover-rpm-ostree
    sddm-kcm
)
dnf5 -y remove "${REMOVE_PACKAGES[@]}"

dnf5 -y config-manager setopt fedora-cisco-openh264.enabled=1

INSTALL_PACKAGES=(
    cascadia-fonts-all
    du-dust
    duf
    fastfetch
    fd
    fzf
    grsync
    htop
    hunspell-it
    hwinfo
    hyperfine
    libnatpmp
    lm_sensors
    lshw
    mc
    mozilla-openh264
    ncdu
    openh264
    policycoreutils-gui
    powerstat
    powertop
    rclone
    ripgrep
    syncthing
    tldr
    traceroute
    xsane
)
dnf5 -y install "${INSTALL_PACKAGES[@]}"
