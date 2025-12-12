#!/bin/bash
set -oue pipefail

KDE_PACKAGES=(
    kamoso
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
)
dnf5 -y install "${KDE_PACKAGES[@]}"

./ctx/cleanup.sh
