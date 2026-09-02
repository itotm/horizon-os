#!/bin/bash
set -oue pipefail

PROTONVPN_PACKAGES=(
    proton-vpn-gtk-app
    proton-vpn-cli
)

REPO_BASE="https://repo.protonvpn.com/fedora-$(rpm -E %fedora)-stable"

RELEASE_RPM=$(curl --http1.1 --retry 3 --retry-delay 10 -fsSL "${REPO_BASE}/protonvpn-stable-release/" \
  | grep -o 'protonvpn-stable-release-[0-9][0-9.]*-[0-9]*\.noarch\.rpm' \
  | sort -V \
  | tail -n1)

if [ -z "${RELEASE_RPM}" ]; then
    echo "ERROR: no protonvpn-stable-release RPM found at ${REPO_BASE}" >&2
    exit 1
fi

curl --http1.1 --retry 3 --retry-delay 10 -fsSL -o "/tmp/protonvpn-stable-release.rpm" \
    "${REPO_BASE}/protonvpn-stable-release/${RELEASE_RPM}"

echo "Installing ${RELEASE_RPM}"
dnf5 -y install "/tmp/protonvpn-stable-release.rpm"
dnf5 -y install "${PROTONVPN_PACKAGES[@]}"

rm -f "/tmp/protonvpn-stable-release.rpm"
