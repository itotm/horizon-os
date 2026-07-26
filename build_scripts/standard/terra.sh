#!/bin/bash
set -oue pipefail

dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

TERRA_PACKAGES=(
    cleartype-fonts
    ms-core-fonts
    sticky
    tail-tray
)
dnf5 -y install "${TERRA_PACKAGES[@]}"
