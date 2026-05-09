#!/bin/bash
set -oue pipefail

KDE_PACKAGES=(
    elisa-player
    gwenview
    isoimagewriter
    k3b
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
    krename
    krusader
    ksystemlog
    okular
    skanlite
    skanpage
)
dnf5 -y install "${KDE_PACKAGES[@]}"
