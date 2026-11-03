#!/bin/bash
set -oue pipefail

SUNSHINE_RPM=$(curl --http1.1 -fsSL \
  "https://api.github.com/repos/LizardByte/Sunshine/releases/latest" \
  | grep -o '"browser_download_url": "[^"]*\.fc'"${FEDORA_VERSION}"'\.x86_64\.rpm"' \
  | cut -d'"' -f4)

curl --http1.1 --retry 3 --retry-delay 10 -fsSL -o "/tmp/sunshine.rpm" "${SUNSHINE_RPM}"
dnf5 -y install "/tmp/sunshine.rpm"
rm -f "/tmp/sunshine.rpm"

# Keep the kernel from handing out Sunshine's streaming ports as ephemeral
# source ports, which would make Sunshine fail to bind them.
echo 'net.ipv4.ip_local_reserved_ports = 47984-48010' > /usr/lib/sysctl.d/90-sunshine.conf
