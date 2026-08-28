#!/bin/bash
set -oue pipefail

# Tooling di virtualizzazione (gestione, distrobox, compose)
VIRT_TOOLS_PACKAGES=(
    cockpit-machines
    distrobox
    podman-compose
    virt-manager
    virt-viewer
)
dnf5 -y install "${VIRT_TOOLS_PACKAGES[@]}"
