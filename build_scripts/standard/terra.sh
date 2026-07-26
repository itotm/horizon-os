#!/bin/bash
set -oue pipefail

dnf -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

TERRA_PACKAGES=(
    tail-tray
)
dnf5 -y install "${TERRA_PACKAGES[@]}"
