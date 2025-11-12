#!/bin/bash
set -ouex pipefail

NOMACHINE_RPM="nomachine_9.2.18_3_x86_64.rpm"
NOMACHINE_URL="https://web9001.nomachine.com/download/9.2/Linux/${NOMACHINE_RPM}"

wget "${NOMACHINE_URL}"

dnf5 -y install "${NOMACHINE_RPM}"

rm -f "${NOMACHINE_RPM}"
