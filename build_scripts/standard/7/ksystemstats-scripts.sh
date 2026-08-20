#!/bin/bash
set -oue pipefail

RPM_URL="https://github.com/itotm/ksystemstats_scripts/releases/download/v1.0/ksystemstats-scripts-1.0-1.fc44.x86_64.rpm"
RPM_FILE="/tmp/ksystemstats-scripts-1.0-1.fc44.x86_64.rpm"

curl -fsSL -o "${RPM_FILE}" "${RPM_URL}"
dnf5 -y install "${RPM_FILE}"
rm -f "${RPM_FILE}"
