#!/bin/bash
set -oue pipefail

# The latest tag is read from the redirect of releases/latest and the RPM name
# from the release's asset list, rather than from api.github.com, whose
# anonymous rate limit is shared by all the runners.
BRIDGE_RELEASES="https://github.com/ProtonMail/proton-bridge/releases"
BRIDGE_TAG=$(curl --http1.1 -fsSLI -o /dev/null -w '%{url_effective}' "${BRIDGE_RELEASES}/latest")
BRIDGE_TAG="${BRIDGE_TAG##*/}"
BRIDGE_RPM=$(curl --http1.1 -fsSL "${BRIDGE_RELEASES}/expanded_assets/${BRIDGE_TAG}" \
  | grep -o "/releases/download/${BRIDGE_TAG}/protonmail-bridge-[^\"/]*\.x86_64\.rpm\"" \
  | cut -d/ -f5 \
  | tr -d '"' \
  | head -n1)
echo "----------> Installing ${BRIDGE_RPM}"

curl --http1.1 --retry 3 --retry-delay 10 -fsSL -o "/tmp/protonmail-bridge.rpm" "${BRIDGE_RELEASES}/download/${BRIDGE_TAG}/${BRIDGE_RPM}"

# The RPM is signed with Proton's Bridge key: the key comes from proton.me, not
# from the GitHub release, and rpm -K fails the build unless the signature
# checks out against it.
rpm --import https://proton.me/download/bridge/bridge_pubkey.gpg
rpm -K "/tmp/protonmail-bridge.rpm"

dnf5 -y install "/tmp/protonmail-bridge.rpm"
rm -f "/tmp/protonmail-bridge.rpm"
