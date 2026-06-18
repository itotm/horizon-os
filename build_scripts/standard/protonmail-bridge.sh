#!/bin/bash
set -oue pipefail

BRIDGE_RPM=$(curl --http1.1 -fsSL \
  "https://api.github.com/repos/ProtonMail/proton-bridge/releases/latest" \
  | grep -o '"browser_download_url": "[^"]*x86_64\.rpm"' \
  | grep -v '\.sig' \
  | cut -d'"' -f4)

curl --http1.1 --retry 3 --retry-delay 10 -fsSL -o "/tmp/protonmail-bridge.rpm" "${BRIDGE_RPM}"
dnf5 -y install "/tmp/protonmail-bridge.rpm"
rm -f "/tmp/protonmail-bridge.rpm"
