#!/bin/bash

set -ouex pipefail

INSTALL_PACKAGES=(
    cascadia-fonts-all
    mc
    htop
    fastfetch
    hwinfo
    kate
    hunspell-it
    qemu-kvm
    cifs-utils
    cockpit
    cockpit-machines
    cockpit-podman
    distrobox
    syncthing
    tailscale
    thunderbird
    qt6-qdbusviewer
)
dnf5 -y install "${INSTALL_PACKAGES[@]}"

REMOVE_PACKAGES=(
    plasma-discover-rpm-ostree
)
dnf5 -y remove "${REMOVE_PACKAGES[@]}"

# RPM Fusion
dnf5 -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf5 -y install rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted
dnf5 -y config-manager setopt fedora-cisco-openh264.enabled=1

dnf5 -y install intel-media-driver
dnf5 -y install libdvdcss

dnf5 -y remove \
    fdk-aac-free \
    libavcodec-free \
    libavdevice-free \
    libavfilter-free \
    libavformat-free \
    libavutil-free \
    libpostproc-free \
    libswresample-free \
    libswscale-free \
    ffmpeg-free
dnf5 -y install ffmpeg

dnf5 -y install \
    gstreamer1-plugin-libav \
    gstreamer1-plugins-bad-free-extras \
    gstreamer1-plugins-bad-freeworld \
    gstreamer1-plugins-ugly \
    gstreamer1-vaapi

# Sunshine
dnf5 -y copr enable lizardbyte/beta
dnf5 -y install Sunshine
dnf5 -y copr disable lizardbyte/beta

systemctl enable podman.socket
systemctl enable cockpit.socket

systemctl enable sshd
systemctl enable tailscaled

# Bash configuration
cat > /etc/inputrc <<EOF
set completion-ignore-case On
EOF

# Info
BUILD_DATE=$(date +'%Y%m%d')
cat > /etc/xdg/kcm-about-distrorc <<EOF
[General]
Variant=HorizonOS ${BUILD_DATE}
Website=https://github.com/itotm/horizon-os
END
EOF

dnf5 clean all
