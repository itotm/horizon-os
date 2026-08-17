#!/bin/bash
set -oue pipefail

# nct6687d
dnf5 -y install kernel-devel automake gcc gcc-c++ kernel-headers dkms

BUILD_DIR="/tmp/nct6687d-build"
mkdir -p "${BUILD_DIR}"

cd "${BUILD_DIR}"

git clone https://github.com/itotm/nct6687d.git
cd nct6687d

make build

KERNEL_VERSION=$(ls -1 /usr/lib/modules/ | head -n1)
cp ${BUILD_DIR}/nct6687d/${KERNEL_VERSION}/nct6687.ko /lib/modules/${KERNEL_VERSION}/kernel/drivers/hwmon/

#mkdir -p /etc/modules-load.d
#echo "nct6687" >> /etc/modules-load.d/nct6687.conf

cd /
rm -rf "${BUILD_DIR}"

# corefreq
dnf5 -y copr enable sunnyyang/corefreq
dnf5 -y install corefreq
dnf5 -y copr disable sunnyyang/corefreq

akmods --force --kernels "${KERNEL_VERSION}" 2>&1 || true

depmod -a "${KERNEL_VERSION}" 2>&1 || true

dnf5 -y remove kernel-devel automake gcc gcc-c++ kernel-headers dkms
