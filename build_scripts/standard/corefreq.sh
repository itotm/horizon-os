#!/bin/bash
set -oue pipefail

dnf5 -y copr enable sunnyyang/corefreq
dnf5 -y install corefreq kernel-devel
dnf5 -y copr disable sunnyyang/corefreq

for KVER in /usr/lib/modules/*; do
    if [ -d "$KVER" ]; then
        KERNEL_VERSION=$(basename "$KVER")
        akmods --force --kernels "${KERNEL_VERSION}"
    fi
done

depmod -a
