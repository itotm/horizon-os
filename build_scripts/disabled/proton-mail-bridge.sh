#!/bin/bash
set -oue pipefail

BRIDGE_URL=$(curl --http1.1 --retry 3 --retry-delay 10 -fsSL \
  "https://api.github.com/repos/ProtonMail/proton-bridge/releases/latest" \
  | grep -o '"browser_download_url": "[^"]*x86_64\.rpm"' \
  | cut -d'"' -f4)

if [ -z "${BRIDGE_URL}" ]; then
  echo "Error: no x86_64 RPM found in the latest proton-bridge release" >&2
  exit 1
fi

echo "Installing Proton Mail Bridge from: ${BRIDGE_URL}"

curl --http1.1 --retry 3 --retry-delay 10 -fsSL -o "/tmp/protonmail-bridge.rpm" "${BRIDGE_URL}"
dnf5 -y install "/tmp/protonmail-bridge.rpm"
rm -f "/tmp/protonmail-bridge.rpm"
