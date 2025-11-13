#!/bin/bash
set -ouex pipefail

# rm /opt && mkdir /opt

# Bash configuration
cat > /etc/inputrc <<EOF
set completion-ignore-case On
EOF

# Colors, themes
./ctx/download_github.sh https://github.com/itotm/plasma-colors/tree/main/color-schemes /usr/share/color-schemes
./ctx/download_github.sh https://github.com/itotm/plasma-colors/tree/main/ClearSimple /usr/share/plasma/desktoptheme/ClearSimple
./ctx/download_github.sh https://github.com/itotm/plasma-colors/tree/main/colored-plasma-logo /usr/share/plasma/look-and-feel/colored-plasma-logo
./ctx/download_github.sh https://github.com/itotm/plymouth-themes/tree/main/fedora-logo /usr/share/plymouth/themes/fedora-logo

