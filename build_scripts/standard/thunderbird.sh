#!/bin/bash
set -oue pipefail

dnf5 config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:/Ximi1970:/Mozilla:/Add-ons/Fedora_43/home:Ximi1970:Mozilla:Add-ons.repo
dnf5 -y install thunderbird systray-x

# force X11 backend for Thunderbird to make systray-x work
DESKTOP_FILE="/usr/share/applications/net.thunderbird.Thunderbird.desktop"
if grep -q '^Exec=' "${DESKTOP_FILE}"; then
    sed -i 's|^Exec=|Exec=env GDK_BACKEND=x11 |' "${DESKTOP_FILE}"
fi

BRIDGE_VERSION="3.22.0"
BRIDGE_RPM="protonmail-bridge-${BRIDGE_VERSION}-1.x86_64.rpm"
BRIDGE_URL="https://proton.me/download/bridge/${BRIDGE_RPM}"

curl -fsSL -o "/tmp/${BRIDGE_RPM}" "${BRIDGE_URL}"
dnf5 -y install "/tmp/${BRIDGE_RPM}"
rm -f "/tmp/${BRIDGE_RPM}"
