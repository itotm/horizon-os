#!/bin/bash
set -oue pipefail

dnf5 config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:/Ximi1970:/Mozilla:/Add-ons/Fedora_43/home:Ximi1970:Mozilla:Add-ons.repo
dnf5 -y install thunderbird systray-x

# force X11 backend for Thunderbird to make systray-x work
DESKTOP_FILE="/usr/share/applications/net.thunderbird.Thunderbird.desktop"
if grep -q '^Exec=' "${DESKTOP_FILE}"; then
    sed -i 's|^Exec=|Exec=env GDK_BACKEND=x11 |' "${DESKTOP_FILE}"
fi

BRIDGE_RPM=$(curl --http1.1 -fsSL \
  "https://api.github.com/repos/ProtonMail/proton-bridge/releases/latest" \
  | grep -o '"browser_download_url": "[^"]*x86_64\.rpm"' \
  | grep -v '\.sig' \
  | cut -d'"' -f4)

curl --http1.1 --retry 3 --retry-delay 10 -fsSL -o "/tmp/protonmail-bridge.rpm" "${BRIDGE_RPM}"
dnf5 -y install "/tmp/protonmail-bridge.rpm"
rm -f "/tmp/protonmail-bridge.rpm"
