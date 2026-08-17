#!/bin/bash
set -oue pipefail

BTRFS_PACKAGES=(
    snapper
    btrfs-assistant
)
dnf5 -y install "${BTRFS_PACKAGES[@]}"
