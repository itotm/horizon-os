#!/bin/bash
set -oue pipefail

BRIDGE_VERSION="3.21.2"
BRIDGE_RPM="protonmail-bridge-${BRIDGE_VERSION}-1.x86_64.rpm"
BRIDGE_URL="https://proton.me/download/bridge/${BRIDGE_RPM}"

curl -fsSL -o "/tmp/${BRIDGE_RPM}" "${BRIDGE_URL}"
dnf5 -y install "/tmp/${BRIDGE_RPM}"
rm -f "/tmp/${BRIDGE_RPM}"
