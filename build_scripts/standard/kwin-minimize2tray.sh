#!/usr/bin/env bash
set -euo pipefail

RPM_URL="https://github.com/itotm/kwin-minimize2tray/releases/download/20260510/kwin-minimize2tray-20260510-1.fc44.x86_64.rpm"
RPM_FILE="/tmp/kwin-minimize2tray-20260510-1.fc44.x86_64.rpm"

curl -fsSL -o "${RPM_FILE}" "${RPM_URL}"
dnf5 -y install "${RPM_FILE}"
rm -f "${RPM_FILE}"
