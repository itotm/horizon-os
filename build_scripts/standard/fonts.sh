#!/bin/bash
set -oue pipefail

FONT_PACKAGES=(
    adobe-source-sans-pro-fonts
    adobe-source-serif-pro-fonts
    alerque-libertinus-fonts
    cascadia-mono-fonts
    intel-one-mono-fonts
    liberation-fonts-all
    jetbrains-mono-fonts
)
dnf5 -y install "${FONT_PACKAGES[@]}"
