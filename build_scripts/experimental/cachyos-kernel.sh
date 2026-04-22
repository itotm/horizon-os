#!/bin/bash
set -oue pipefail

dnf5 -y remove \
    kernel \
    kernel-* &&
    rm -r -f /usr/lib/modules/*

dnf5 -y copr enable bieszczaders/kernel-cachyos-lto

dnf5 -y install --setopt=install_weak_deps=False --setopt=tsflags=noscripts kernel-cachyos-lto

KVER=$(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-cachyos-lto-core)
depmod -a "${KVER}"

dnf5 -y copr disable bieszczaders/kernel-cachyos-lto

setsebool -P domain_kernel_load_modules on
