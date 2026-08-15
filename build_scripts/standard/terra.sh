#!/bin/bash
set -oue pipefail

TERRA_PACKAGES=(
    cleartype-fonts
    ms-core-fonts
    tail-tray
)

dnf5 -y install \
    --nogpgcheck \
    --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
    "${TERRA_PACKAGES[@]}"