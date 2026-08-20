#!/bin/bash
set -oue pipefail

HEAVY_PACKAGES=(
    rclone
    syncthing
    vlc
    yt-dlp
)
dnf5 -y install "${HEAVY_PACKAGES[@]}"
