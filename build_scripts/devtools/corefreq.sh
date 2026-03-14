#!/bin/bash
set -oue pipefail

KERNEL_VERSION=$(ls -1 /usr/lib/modules/ | head -n1)
KERNEL_PKG_VERSION=$(echo "${KERNEL_VERSION}" | sed 's/\.x86_64$//')

dnf5 -y install "kernel-devel-${KERNEL_PKG_VERSION}" gcc
BUILD_DIR="/tmp/corefreq-build"

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

git clone --depth 1 https://github.com/cyring/CoreFreq.git
cd CoreFreq

make -j KERNELREL="/lib/modules/${KERNEL_VERSION}"
make install KERNELREL="/lib/modules/${KERNEL_VERSION}"

depmod -a "${KERNEL_VERSION}" 2>&1 || true

mkdir -p /etc/modules-load.d
echo "corefreqk" > /etc/modules-load.d/corefreqk.conf
systemctl enable corefreqd.service

cd /
rm -rf "${BUILD_DIR}"
dnf5 -y remove kernel-devel gcc
