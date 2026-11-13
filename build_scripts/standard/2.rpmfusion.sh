#!/bin/bash
set -oue pipefail

dnf5 -y install \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf5 -y install rpmfusion-free-release-tainted

RPMFUSION_PACKAGES=(
    ffmpeg
    mesa-va-drivers-freeworld
    gstreamer1-plugins-bad-free-extras
    gstreamer1-plugins-bad-freeworld
    gstreamer1-plugins-ugly
    intel-media-driver
    libdvdcss
)
dnf5 -y install --allowerasing "${RPMFUSION_PACKAGES[@]}"
