#!/bin/bash
set -oue pipefail

dnf5 -y install kernel-devel

dnf5 -y copr enable ublue-os/akmods
dnf5 -y install --setopt=tsflags=noscripts akmod-zenpower3 akmod-nct6687d
dnf5 -y copr disable ublue-os/akmods

KERNEL_VERSION=$(ls -1 /usr/lib/modules/ | head -n1)

akmods --force --kernels "${KERNEL_VERSION}" 2>&1 || true

depmod -a "${KERNEL_VERSION}" 2>&1 || true

dnf5 -y remove kernel-devel
