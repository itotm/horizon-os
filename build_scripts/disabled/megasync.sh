#!/bin/bash
set -oue pipefail

MEGA_FEDORA=$(curl --http1.1 -fsSL "https://mega.nz/linux/repo/" \
  | grep -o 'href="Fedora_[0-9]*/"' \
  | grep -o '[0-9]*' \
  | awk -v max="${FEDORA_VERSION}" '$1 <= max' \
  | sort -n \
  | tail -n1)
echo "----------> Using MEGA repository for Fedora ${MEGA_FEDORA}"

MEGA_REPO_BASE="https://mega.nz/linux/repo/Fedora_${MEGA_FEDORA}"
MEGA_REPO="${MEGA_REPO_BASE}/x86_64"

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
rpm --import "${MEGA_REPO_BASE}/repodata/repomd.xml.key"
rpm -ivh --noscripts --badreloc --relocate /opt=/usr/lib/opt "/tmp/megasync.rpm"
rm -f "/tmp/megasync.rpm"

echo "----------> Declaring the /opt/megasync symlink"
cat > /usr/lib/tmpfiles.d/megasync.conf <<'TMPFILES'
L /var/opt/megasync - - - - /usr/lib/opt/megasync
TMPFILES
