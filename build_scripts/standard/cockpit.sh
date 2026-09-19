#!/bin/bash
set -oue pipefail

COCKPIT_PACKAGES=(
    cockpit
    cockpit-files
    cockpit-podman
    cockpit-selinux
)
dnf5 -y install "${COCKPIT_PACKAGES[@]}"

curl --http1.1 --retry 3 --retry-delay 10 -fsSL -o /tmp/cockpit-sensors.tar.xz \
  "https://github.com/ocristopfer/cockpit-sensors/releases/latest/download/cockpit-sensors.tar.xz"
mkdir -p /usr/share/cockpit/sensors
tar -xJf /tmp/cockpit-sensors.tar.xz -C /usr/share/cockpit/sensors --strip-components=2 cockpit-sensors/dist
rm -f /tmp/cockpit-sensors.tar.xz
