#!/bin/bash
set -oue pipefail

dnf5 -y copr enable shdwchn10/zenpower3
dnf5 -y install kernel-devel zenpower3 zenmonitor3
dnf5 -y copr disable shdwchn10/zenpower3

KERNEL_VERSION=$(ls -1 /usr/lib/modules/ | head -n1)

akmods --force --kernels "${KERNEL_VERSION}" 2>&1 || true

depmod -a "${KERNEL_VERSION}" 2>&1 || true

dnf5 -y remove kernel-devel
