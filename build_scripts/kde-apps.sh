#!/bin/bash
set -ouex pipefail

KDE_PACKAGES=(
    kate
    elisa-player
    gwenview
    kcalc
    kolourpaint
    krdc
    okular
    skanpage
    qt6-qdbusviewer
)
dnf5 -y install "${KDE_PACKAGES[@]}"

./ctx/cleanup.sh
