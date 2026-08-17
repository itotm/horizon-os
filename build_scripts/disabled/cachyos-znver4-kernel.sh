#!/bin/bash
set -oue pipefail

dnf5 -y copr enable itotm/cachyos-kernel-znver4

# Disable rpmostree kernel install hook to prevent it from running dracut prematurely
mv /usr/lib/kernel/install.d/05-rpmostree.install \
   /usr/lib/kernel/install.d/05-rpmostree.install.disabled

dnf5 -y remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra

# initramfs rebuilt in common.sh
rm -rf /usr/lib/modules/*

dnf5 -y install kernel-cachyos-znver4

mv /usr/lib/kernel/install.d/05-rpmostree.install.disabled \
   /usr/lib/kernel/install.d/05-rpmostree.install

dnf5 -y copr disable itotm/cachyos-kernel-znver4
