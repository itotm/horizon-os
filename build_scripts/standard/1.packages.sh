#!/bin/bash
set -oue pipefail

sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

REMOVE_PACKAGES=(
    kde-connect
    plasma-discover-rpm-ostree
    virtualbox-guest-additions
)
dnf5 -y remove "${REMOVE_PACKAGES[@]}"

dnf5 -y config-manager setopt fedora-cisco-openh264.enabled=1

INSTALL_PACKAGES=(
    btrfs-assistant
    cascadia-fonts-all
    du-dust
    duf
    fastfetch
    fd
    fuse
    fuse-libs
    fzf
    git
    grsync
    htop
    hunspell-it
    hunspell-la
    hunspell-cs
    hunspell-fr
    hwinfo
    hyperfine
    imapsync
    libnatpmp
    libva-utils
    lm_sensors
    lshw
    mc
    mozilla-openh264
    ncdu
    nvtop
    openh264
    plasma-union
    policycoreutils-gui
    powerstat
    powertop
    rclone
    ripgrep
    snapper
    syncthing
    tldr
    tmux
    traceroute
    vlc
    xsane
)
dnf5 -y install "${INSTALL_PACKAGES[@]}"
