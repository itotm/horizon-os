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

MEGACMD_RPM=$(curl --http1.1 -fsSL "${MEGA_REPO}/" \
  | grep -o 'href="megacmd-[0-9][^"]*\.x86_64\.rpm"' \
  | cut -d'"' -f2 \
  | sort -V \
  | tail -n1)

MEGACMD_DEPS=(
    fuse
    fuse-libs
    libatomic
    procps-ng
)
dnf5 -y install "${MEGACMD_DEPS[@]}"

# The scriptlets are skipped: they only add the MEGA repository to
# /etc/yum.repos.d, import its key and apply the inotify sysctl, which the
# package's own /etc/sysctl.d file does at boot anyway.
curl --http1.1 --retry 3 --retry-delay 10 -fsSL -o "/tmp/megacmd.rpm" "${MEGA_REPO}/${MEGACMD_RPM}"
rpm --import "${MEGA_REPO_BASE}/repodata/repomd.xml.key"
rpm -ivh --noscripts --badreloc --relocate /opt=/usr/lib/opt "/tmp/megacmd.rpm"
rm -f "/tmp/megacmd.rpm"

# mega-cmd, mega-cmd-server and mega-exec load the bundled FFmpeg through the
# RUNPATH /opt/megacmd/lib, and /opt is a link to /var/opt.
echo "----------> Declaring the /opt/megacmd symlink"
cat > /usr/lib/tmpfiles.d/megacmd.conf <<'TMPFILES'
L /var/opt/megacmd - - - - /usr/lib/opt/megacmd
TMPFILES

# Syncs, backups and WebDAV only run while mega-cmd-server does: the mega-*
# commands start it in the background on first use, and it goes away with the
# session. This user unit keeps it running from login; it ships disabled and
# each user turns it on with: systemctl --user enable --now mega-cmd-server
echo "----------> Adding the mega-cmd-server user service (disabled)"
cat > /usr/lib/systemd/user/mega-cmd-server.service <<'UNIT'
[Unit]
Description=MEGAcmd server (MEGA syncs and backups)
Documentation=https://github.com/meganz/MEGAcmd

[Service]
ExecStart=/usr/bin/mega-cmd-server
Restart=on-failure
RestartSec=30

[Install]
WantedBy=default.target
UNIT
