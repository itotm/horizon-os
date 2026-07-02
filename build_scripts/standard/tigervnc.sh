#!/bin/bash
set -oue pipefail

TIGERVNC_PACKAGES=(
    tigervnc
    tigervnc-selinux
    tigervnc-server
    tigervnc-wayland-server
)
dnf5 -y install "${TIGERVNC_PACKAGES[@]}"
