#!/bin/bash
set -oue pipefail

# Backrest is not packaged in Fedora: install the latest release binary.
# restic is not installed: Backrest downloads the version it needs into its
# data directory and checks it against the restic maintainers' signature.
BACKREST_TAG=$(curl --http1.1 -fsSL \
  "https://api.github.com/repos/garethgeorge/backrest/releases/latest" \
  | grep -o '"tag_name": "[^"]*"' \
  | cut -d'"' -f4)
BACKREST_VERSION="${BACKREST_TAG#v}"
BACKREST_URL="https://github.com/garethgeorge/backrest/releases/download/${BACKREST_TAG}"
echo "----------> Installing Backrest ${BACKREST_VERSION}"

mkdir -p /tmp/backrest
curl --http1.1 --retry 3 --retry-delay 10 -fsSL -o "/tmp/backrest/backrest_Linux_x86_64.tar.gz" "${BACKREST_URL}/backrest_Linux_x86_64.tar.gz"
curl --http1.1 --retry 3 --retry-delay 10 -fsSL -o "/tmp/backrest/checksums.txt" "${BACKREST_URL}/backrest_${BACKREST_VERSION}_checksums.txt"
(cd /tmp/backrest && grep ' backrest_Linux_x86_64.tar.gz$' checksums.txt | sha256sum --check)

tar -xzf /tmp/backrest/backrest_Linux_x86_64.tar.gz -C /tmp/backrest backrest LICENSE
install -m 0755 /tmp/backrest/backrest /usr/bin/backrest
install -D -m 0644 /tmp/backrest/LICENSE /usr/share/licenses/backrest/LICENSE
rm -rf /tmp/backrest
