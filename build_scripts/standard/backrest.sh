#!/bin/bash
set -oue pipefail

# Backrest is not packaged in Fedora: install the latest release binary.
# restic is not installed: Backrest downloads the version it needs into its
# data directory and checks it against the restic maintainers' signature.
# The latest tag is read from the redirect of releases/latest rather than from
# api.github.com, whose anonymous rate limit is shared by all the runners.
BACKREST_TAG=$(curl --http1.1 -fsSLI -o /dev/null -w '%{url_effective}' \
  "https://github.com/garethgeorge/backrest/releases/latest")
BACKREST_TAG="${BACKREST_TAG##*/}"
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
