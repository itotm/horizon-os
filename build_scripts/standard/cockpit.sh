#!/bin/bash
set -oue pipefail

COCKPIT_PACKAGES=(
    cockpit
    cockpit-podman
    cockpit-selinux
)
dnf5 -y install "${COCKPIT_PACKAGES[@]}"
