#!/bin/bash
set -oue pipefail

EXTENDED_PACKAGES=(
    amule
    piper
)
dnf5 -y install "${EXTENDED_PACKAGES[@]}"
