#!/bin/bash
set -oue pipefail

dnf5 -y install kernel-devel

dnf5 -y copr enable shdwchn10/zenpower3
dnf5 -y install --setopt=tsflags=noscripts akmod-zenpower3
dnf5 -y install zenmonitor3
dnf5 -y copr disable shdwchn10/zenpower3

KERNEL_VERSION=$(ls -1 /usr/lib/modules/ | head -n1)

akmods --force --kernels "${KERNEL_VERSION}" 2>&1 || true

depmod -a "${KERNEL_VERSION}" 2>&1 || true

dnf5 -y remove kernel-devel
