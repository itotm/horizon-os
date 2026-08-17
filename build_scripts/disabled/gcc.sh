#!/bin/bash
set -oue pipefail

GCC_PACKAGES=(
    gcc
    gcc-c++
    kernel-devel
    make
)
dnf5 -y install "${GCC_PACKAGES[@]}"
