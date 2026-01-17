#!/bin/bash
set -oue pipefail

# nct6687d
dnf5 -y install kernel-devel git

BUILD_DIR="/tmp/nct6687d-build"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

git clone https://github.com/Fred78290/nct6687d.git
cd nct6687d

mkdir -p /root/rpmbuild/{build,rpms,sources,specs,srpms}
make akmod

mkdir -p /etc/modules-load.d
echo "nct6687" >> /etc/modules-load.d/nct6687.conf

cd /
rm -rf "${BUILD_DIR}"
rm -rf ~/rpmbuild

# corefreq
dnf5 -y copr enable sunnyyang/corefreq
dnf5 -y install corefreq
dnf5 -y copr disable sunnyyang/corefreq

KERNEL_VERSION=$(ls -1 /usr/lib/modules/ | head -n1)

akmods --force --kernels "${KERNEL_VERSION}" 2>&1 || true

depmod -a "${KERNEL_VERSION}" 2>&1 || true

dnf5 -y remove kernel-devel git
