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
    kdiskmark
    kmahjongg
    kmines
    kolourpaint
    kompare
    kommit
    kpat
    krdc
    ksystemlog
    okular
    skanlite
    skanpage
    smb4k
)
dnf5 -y install "${KDE_PACKAGES[@]}"
