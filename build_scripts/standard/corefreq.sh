#!/bin/bash
set -oue pipefail

dnf5 -y copr enable sunnyyang/corefreq
dnf5 -y install corefreq
dnf5 -y copr disable sunnyyang/corefreq

KERNEL_VERSION=$(ls -1 /usr/lib/modules/ | head -n1)

akmods --force --kernels "${KERNEL_VERSION}" 2>&1 | grep -v "could not open directory" || true

depmod -a "${KERNEL_VERSION}" 2>&1 | grep -v "azure" || true

dnf5 -y remove corefreq
