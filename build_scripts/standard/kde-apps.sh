#!/bin/bash
set -oue pipefail

KDE_PACKAGES=(
    kate
    kdiff3
    kid3
    elisa-player
    gwenview
    kcalc
    kolourpaint
    krdc
    ksystemlog
    okular
    skanpage
)
dnf5 -y install "${KDE_PACKAGES[@]}"

./ctx/cleanup.sh
