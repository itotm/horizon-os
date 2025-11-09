#!/bin/bash

set -ouex pipefail

SERVER_PACKAGES=(
    mc
    hunspell-it
    qemu
    cockpit
    cockpit-machines
    cockpit-podman
    fastfetch
    syncthing
    tailscale
    gimp
    libreoffice
    thunderbird
    qt6-qdbusviewer
)

dnf5 install -y "${SERVER_PACKAGES[@]}"


dnf5 -y copr enable lizardbyte/stable
#dnf5 -y install Sunshine
dnf5 search Sunshine
dnf5 -y copr disable lizardbyte/stable


systemctl enable podman.socket
systemctl enable cockpit.socket


BUILD_DATE=$(date +'%Y%m%d')
cat > /etc/xdg/kcm-about-distrorc <<EOF
[General]
Variant=HorizonOS ${BUILD_DATE}
Website=https://github.com/itotm/horizon-os
END
EOF