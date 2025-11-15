#!/bin/bash
set -ouex pipefail

DOTNET_PACKAGES=(
    glibc
    libgcc
    ca-certificates
    openssl-libs
    libstdc++
    libicu
    tzdata
    krb5-libs
    zlib
    dotnet-sdk-10.0
)
dnf5 -y install "${DOTNET_PACKAGES[@]}"

./ctx/cleanup.sh
