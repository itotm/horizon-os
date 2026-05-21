#!/bin/bash
set -oue pipefail

dnf5 -y copr enable bieszczaders/kernel-cachyos-lto

mv /usr/lib/kernel/install.d/05-rpmostree.install \
   /usr/lib/kernel/install.d/05-rpmostree.install.disabled

dnf5 -y remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra
dnf5 -y install kernel-cachyos-lto

mv /usr/lib/kernel/install.d/05-rpmostree.install.disabled \
   /usr/lib/kernel/install.d/05-rpmostree.install

KVER=$(ls /usr/lib/modules/ | grep cachyos | head -1)
echo "Kernel: ${KVER}"

depmod -a "${KVER}"
kernel-install add "${KVER}" /usr/lib/modules/${KVER}/vmlinuz

setsebool -P domain_kernel_load_modules on

dnf5 -y copr disable bieszczaders/kernel-cachyos-lto