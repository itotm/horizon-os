#!/bin/bash
set -ouex pipefail

rm /opt && mkdir /opt

# Bash configuration
cat > /etc/inputrc <<EOF
set completion-ignore-case On
EOF

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

# Colors, themes
./download_github.sh https://github.com/itotm/plasma-colors/tree/main/color-schemes /usr/share/color-schemes
./download_github.sh https://github.com/itotm/plasma-colors/tree/main/ClearSimple /usr/share/plasma/desktoptheme/ClearSimple
./download_github.sh https://github.com/itotm/plasma-colors/tree/main/colored-plasma-logo /usr/share/plasma/look-and-feel/colored-plasma-logo
./download_github.sh https://github.com/itotm/plymouth-themes/tree/main/fedora-logo /usr/share/plymouth/themes/fedora-logo

