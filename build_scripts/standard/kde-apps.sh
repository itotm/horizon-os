#!/bin/bash
set -oue pipefail

KDE_PACKAGES=(
    elisa-player
    gwenview
    isoimagewriter
    kamoso
    kate
    kcalc
    kcolorchooser
    kdiff3
    kdiskmark
    kmahjongg
    kmines
    kid3
    kolourpaint
    kompare
    kommit
    kpat
    krusader
    ksystemlog
    okular
    skanlite
    skanpage
    smb4k
)
dnf5 -y install "${KDE_PACKAGES[@]}"
