#!/bin/bash
set -oue pipefail

dnf5 -y install https://repo.protonvpn.com/fedora-$(rpm -E %fedora)-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.3-1.noarch.rpm

PROTON_PACKAGES=(
    proton-vpn-cli
    proton-vpn-gnome-desktop
    libappindicator-gtk3
    gnome-shell-extension-appindicator
    gnome-extensions-app
)
dnf5 -y install "${PROTON_PACKAGES[@]}"
