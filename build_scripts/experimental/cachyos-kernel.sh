#!/bin/bash
set -oue pipefail

dnf5 -y copr enable bieszczaders/kernel-cachyos-lto

rpm-ostree override remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra \
    --install kernel-cachyos-lto

ostree container commit

dnf5 -y copr disable bieszczaders/kernel-cachyos-lto
