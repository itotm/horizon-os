#!/bin/bash
set -oue pipefail

# MEGAsync desktop client from MEGA's own Fedora repository. Only the client
# is installed; the dolphin/nautilus/nemo/thunar integration packages that sit
# next to it are not wanted. The version is not pinned: the latest RPM in the
# repository listing is picked at build time, as the other scripts do with
# GitHub releases.
#
# It is installed with rpm rather than dnf so nothing gets resolved behind our
# back: the dependencies are listed here explicitly, and rpm aborts the build
# if one of them is missing. The scriptlets are skipped as well: %post drops a
# megasync.repo in /etc/yum.repos.d and imports MEGA's signing key into the rpm
# database (moving the rpm lock file aside to do so from inside a transaction),
# neither of which is of any use on an image whose repositories are all
# disabled, and it runs sysctl -p on the shipped inotify limit, which fails in
# a build container anyway; the file is installed and applied at boot. The icon
# cache is still refreshed by the gtk-update-icon-cache file trigger, which
# --noscripts does not disable.
#
# The package puts its bundled ffmpeg libraries under /opt/megasync/lib and the
# binaries find them there through their RUNPATH. On a bootc image /opt is a
# symlink to /var/opt and /var only comes from the image at install time, so on
# an already deployed machine those files would never appear. They are
# relocated to /usr/lib/opt instead (--badreloc, since the package does not
# declare /opt as relocatable) and /var/opt/megasync is a symlink back to them,
# declared in tmpfiles.d so that it is recreated on every boot.

MEGA_REPO="https://mega.nz/linux/repo/Fedora_${FEDORA_VERSION}/x86_64"

MEGASYNC_RPM=$(curl --http1.1 -fsSL "${MEGA_REPO}/" \
  | grep -o 'href="megasync-[0-9][^"]*\.x86_64\.rpm"' \
  | cut -d'"' -f2 \
  | sort -V \
  | tail -n1)

MEGASYNC_DEPS=(
    kf5-qqc2-desktop-style
    libatomic
    qt5-qtbase
    qt5-qtdeclarative
    qt5-qtquickcontrols
    qt5-qtquickcontrols2
    qt5-qtsvg
    qt5-qtx11extras
)
dnf5 -y install "${MEGASYNC_DEPS[@]}"

curl --http1.1 --retry 3 --retry-delay 10 -fsSL -o "/tmp/megasync.rpm" "${MEGA_REPO}/${MEGASYNC_RPM}"
rpm -ivh --noscripts --badreloc --relocate /opt=/usr/lib/opt "/tmp/megasync.rpm"
rm -f "/tmp/megasync.rpm"

echo "----------> Linking /opt/megasync to /usr/lib/opt/megasync"
ln -s /usr/lib/opt/megasync /var/opt/megasync
cat > /usr/lib/tmpfiles.d/megasync.conf <<'TMPFILES'
L /var/opt/megasync - - - - /usr/lib/opt/megasync
TMPFILES
