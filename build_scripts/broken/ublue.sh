#!/bin/bash
set -oue pipefail

dnf5 -y copr enable ublue-os/akmods
dnf5 -y install akmod-zenpower3 akmod-nct6687d kernel-devel
dnf5 -y copr disable ublue-os/akmods

KERNEL_VERSION=$(ls -1 /usr/lib/modules/ | head -n1)

akmods --force --kernels "${KERNEL_VERSION}" 2>&1 || true

depmod -a "${KERNEL_VERSION}" 2>&1 || true

dnf5 -y remove kernel-devel
