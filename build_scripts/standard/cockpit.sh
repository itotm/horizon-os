#!/bin/bash
set -oue pipefail

COCKPIT_PACKAGES=(
    cockpit
    cockpit-podman
)
dnf5 -y install "${COCKPIT_PACKAGES[@]}"

systemctl enable cockpit.socket

./ctx/cleanup.sh
