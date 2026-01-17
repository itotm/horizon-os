#!/bin/bash
set -oue pipefail

# nct6687d
dnf5 -y install kernel-devel git '@Development Tools' diffstat doxygen gettext patch patchutils subversion systemtap rpmdevtools kmodtool

BUILD_DIR="/tmp/nct6687d-build"
RPMBUILD_DIR="/tmp/rpmbuild"
mkdir -p "${BUILD_DIR}"
mkdir -p "${RPMBUILD_DIR}"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
cd "${BUILD_DIR}"

cat > ~/.rpmmacros << EOF
%_topdir ${RPMBUILD_DIR}
EOF

git clone https://github.com/Fred78290/nct6687d.git
cd nct6687d

mkdir -p ~/rpmbuild/{build,rpms,sources,specs,srpms}
make akmod

mkdir -p /etc/modules-load.d
echo "nct6687" >> /etc/modules-load.d/nct6687.conf

cd /
rm -rf "${BUILD_DIR}"
rm -rf "${RPMBUILD_DIR}"
rm -f ~/.rpmmacros

# corefreq
dnf5 -y copr enable sunnyyang/corefreq
dnf5 -y install corefreq
dnf5 -y copr disable sunnyyang/corefreq

KERNEL_VERSION=$(ls -1 /usr/lib/modules/ | head -n1)

akmods --force --kernels "${KERNEL_VERSION}" 2>&1 || true

depmod -a "${KERNEL_VERSION}" 2>&1 || true

dnf5 -y remove kernel-devel git '@Development Tools' diffstat doxygen gettext patch patchutils subversion systemtap rpmdevtools kmodtool
