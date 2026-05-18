#!/bin/bash
set -oue pipefail

MEET_VERSION="1.0.9"
MEET_RPM="ProtonMeet-desktop.rpm"
MEET_URL="https://proton.me/download/meet/linux/${MEET_VERSION}/${MEET_RPM}"

curl -fsSL -o "/tmp/${MEET_RPM}" "${MEET_URL}"
dnf5 -y install "/tmp/${MEET_RPM}"
rm -f "/tmp/${MEET_RPM}"
