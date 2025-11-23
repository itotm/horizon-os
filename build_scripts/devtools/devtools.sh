#!/bin/bash
set -ouex pipefail

DEV_PACKAGES=(
    distrobox
    qt6-qdbusviewer
)
dnf5 -y install "${DEV_PACKAGES[@]}"

./ctx/cleanup.sh
