#!/bin/bash
set -ouex pipefail

# Version info
BUILD_DATE=$(date +'%Y%m%d')
BUILD_NUMBER=${BUILD_NUMBER:-1}
VERSION="${BUILD_DATE}.${BUILD_NUMBER}"

cat > /etc/xdg/kcm-about-distrorc <<EOF
[General]
Variant=HorizonOS ${VERSION}
Website=https://github.com/itotm/horizon-os
EOF

# Save version info for reference
echo "${VERSION}" > /etc/horizon-version

dnf5 -y clean all
sed -i 's/^enabled=.*/enabled=0/' /etc/yum.repos.d/*.repo
