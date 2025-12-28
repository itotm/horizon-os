#!/bin/bash
set -oue pipefail

KDE_PACKAGES=(
    kamoso
    kate
    kdiff3
    kid3
    elisa-player
    gwenview
    isoimagewriter
    kcalc
    kcolorchooser
    kolourpaint
    krdc
    ksystemlog
    okular
    skanlite
    skanpage   
)
dnf5 -y install "${KDE_PACKAGES[@]}"
