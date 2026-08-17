#!/usr/bin/env bash
set -euo pipefail

PHONE_PACKAGES=(
    android-tools
)
dnf5 -y install "${PHONE_PACKAGES[@]}"

dnf -y copr enable zeno/scrcpy
dnf5 -y install scrcpy
